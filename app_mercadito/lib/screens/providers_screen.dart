import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final List<String> chips = ['Cercanos', 'Mejor Valorados', 'Verificados', 'Orgánicos', 'Distancia'];
  Set<int> selectedChips = {0};
  double _distance = 10.0;
  bool _isOpenNow = true;

  List<Map<String, dynamic>> get providers => [
    {
      'name': 'Huerta Los Arcos',
      'rating': '4.8',
      'distance': 'A 5 km',
      'verified': true,
      'open': true,
      'closeTime': '18:00',
      'tags': 'Frutas y Verduras Orgánicas',
      'reviews': '120 reseñas de clientes',
      'traded': '1,240 productos negociados',
      'img': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
      'salesType': 'Al Detalle'
    },
    {
      'name': 'Rancho San José',
      'rating': '4.9',
      'distance': 'A 12 km',
      'verified': false,
      'open': true,
      'closeTime': '19:00',
      'tags': 'Lácteos y Quesos Artesanales',
      'reviews': '85 reseñas de clientes',
      'traded': '430 productos negociados',
      'img': 'assets/images/la-siembra-de-la-semilla.webp',
      'salesType': 'Mayorista'
    },
    {
      'name': 'La Granja de Toño',
      'rating': '4.7',
      'distance': 'A 8 km',
      'verified': true,
      'open': true,
      'closeTime': '17:30',
      'tags': 'Huevos de rancho y Aves',
      'reviews': '210 reseñas de clientes',
      'traded': '850 productos negociados',
      'img': 'assets/images/siembra-directa-sobre-campo-argentino-scaled.jpg',
      'salesType': 'Ambos'
    }
  ];

  List<Map<String, dynamic>> get filteredProviders {
    return providers.where((provider) {
      if (selectedChips.contains(1)) {
        double rating = double.tryParse(provider['rating'] ?? '0') ?? 0;
        if (rating < 4.8) return false;
      }
      
      if (selectedChips.contains(2)) {
        if (provider['verified'] != true) return false;
      }
      
      if (selectedChips.contains(3)) {
        String tags = (provider['tags'] ?? '').toLowerCase();
        if (!tags.contains('orgánic')) return false;
      }

      String distStr = provider['distance'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      int dist = int.tryParse(distStr) ?? 0;
      
      if (selectedChips.contains(0) && dist > 10) return false;
      
      if (selectedChips.contains(4) && dist > _distance) return false;
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            Expanded(
              child: filteredProviders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay proveedores',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta quitar algunos filtros.',
                            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[600] : Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                      itemCount: filteredProviders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _buildProviderCard(theme, isDark, filteredProviders[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d).withOpacity(0.9) : const Color(0xFFf5f8f7).withOpacity(0.9),
        border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                  onPressed: () => context.go('/home'),
                ),
                Expanded(
                  child: Text(
                    'Proveedores',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48), // Balance for back button
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.search, color: theme.colorScheme.primary),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar proveedor...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = selectedChips.contains(index);
                IconData icon;
                Color iconColor;
                if (index == 0) {
                  icon = Icons.near_me;
                  iconColor = isSelected ? Colors.white : theme.colorScheme.primary;
                } else if (index == 1) {
                  icon = Icons.star;
                  iconColor = isSelected ? Colors.white : Colors.orange;
                } else if (index == 2) {
                  icon = Icons.verified;
                  iconColor = isSelected ? Colors.white : Colors.blue;
                } else if (index == 3) {
                  icon = Icons.eco;
                  iconColor = isSelected ? Colors.white : Colors.green;
                } else {
                  icon = Icons.map;
                  iconColor = isSelected ? Colors.white : theme.colorScheme.primary;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedChips.contains(index)) {
                        selectedChips.remove(index);
                      } else {
                        selectedChips.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey[800] : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          chips[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[200] : Colors.grey[700]),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedChips.contains(4)) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rango de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[200] : Colors.grey[700])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Hasta ${_distance.toInt()} km', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    Slider(
                      value: _distance,
                      min: 1,
                      max: 50,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) {
                        setState(() {
                          _distance = v;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 km', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        Text('10 km', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        Text('25 km', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        Text('50+ km', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Horario de Atención', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[200] : Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOpenNow = true),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isOpenNow ? theme.colorScheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _isOpenNow ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.2)),
                            ),
                            child: Text('Abierto ahora', style: TextStyle(color: _isOpenNow ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOpenNow = false),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isOpenNow ? theme.colorScheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: !_isOpenNow ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.2)),
                            ),
                            child: Text('Cualquier horario', style: TextStyle(color: !_isOpenNow ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ThemeData theme, bool isDark, Map<String, dynamic> provider) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: (provider['img'] != null && provider['img'].toString().isNotEmpty)
                  ? (provider['img'].toString().startsWith('http')
                      ? Image.network(
                          provider['img'],
                          headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'},
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                              child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                            );
                          },
                        )
                      : (provider['img'].toString().startsWith('assets/')
                          ? Image.asset(
                              provider['img'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                                  child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                                );
                              },
                            )
                          : Container(
                              height: 180,
                              width: double.infinity,
                              color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                              child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                            )))
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                      child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f)),
                    ),
              ),
              if (provider['verified'])
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f172a).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.blue, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'VERIFICADO',
                          style: TextStyle(
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
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    provider['distance'],
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        provider['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            provider['rating'],
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('ABIERTO AHORA', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('• Cierra ${provider['closeTime']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      provider['tags'],
                      style: TextStyle(
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16251E) : const Color(0xFFEAF2E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF23352B) : theme.colorScheme.primary.withOpacity(0.2),
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
                            provider['salesType'] ?? 'Al Detalle',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF8BD8B2) : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.handshake, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      provider['traded'] ?? '0 productos negociados',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600], 
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(provider['reviews'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ElevatedButton(
                      onPressed: () => context.push('/provider', extra: provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: const Size(0, 36), // <- Sobrescribe el 'double.infinity' del tema global
                      ),
                      child: const Text('Ver perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
