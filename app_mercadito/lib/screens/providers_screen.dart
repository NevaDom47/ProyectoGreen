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
  String _selectedSpecialty = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<String> commercialSpecialties = [
    'Frutas y verduras',
    'Cereales y granos',
    'Alimento Animal',
    'Semillas',
    'Lacteos',
    'Huevos',
    'Carnes y Embutidos',
    'Otros',
  ];

  List<String> get specialties => ['Todas', ...commercialSpecialties];

  List<Map<String, dynamic>> get providers => [
    {
      'name': 'Huerta Los Arcos',
      'rating': '4.8',
      'sector': 'Sector San Pedro',
      'distance': 'A 5 km',
      'level': 'Nivel 3',
      'verified': true,
      'open': true,
      'closeTime': '18:00',
      'tags': 'Frutas y verduras',
      'reviews': '120 reseñas de clientes',
      'traded': '1,240 productos negociados',
      'sales': '1,240',
      'img': 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
      'salesType': 'Al Detalle'
    },
    {
      'name': 'Rancho San José',
      'rating': '4.9',
      'sector': 'Sector El Valle',
      'distance': 'A 12 km',
      'level': 'Nivel 4',
      'verified': false,
      'open': true,
      'closeTime': '19:00',
      'tags': 'Lacteos',
      'reviews': '85 reseñas de clientes',
      'traded': '430 productos negociados',
      'sales': '430',
      'img': 'assets/images/la-siembra-de-la-semilla.webp',
      'salesType': 'Mayorista'
    },
    {
      'name': 'La Granja de Toño',
      'rating': '4.7',
      'sector': 'Sector El Salto',
      'distance': 'A 8 km',
      'level': 'Nivel 2',
      'verified': true,
      'open': true,
      'closeTime': '17:30',
      'tags': 'Huevos',
      'reviews': '210 reseñas de clientes',
      'traded': '850 productos negociados',
      'sales': '850',
      'img': 'assets/images/siembra-directa-sobre-campo-argentino-scaled.jpg',
      'salesType': 'Ambos'
    },
    {
      'name': 'Cereales y Granos del Valle',
      'rating': '4.9',
      'sector': 'Sector Monte Alto',
      'distance': 'A 15 km',
      'level': 'Nivel 5',
      'verified': true,
      'open': true,
      'closeTime': '16:00',
      'tags': 'Cereales y granos',
      'reviews': '340 reseñas de clientes',
      'traded': '2,100 productos negociados',
      'sales': '2,100',
      'img': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=600&auto=format&fit=crop',
      'salesType': 'Ambos'
    },
    {
      'name': 'Semillas del Campo',
      'rating': '4.8',
      'sector': 'Sector La Pradera',
      'distance': 'A 6 km',
      'level': 'Nivel 3',
      'verified': true,
      'open': true,
      'closeTime': '18:30',
      'tags': 'Semillas',
      'reviews': '95 reseñas de clientes',
      'traded': '520 productos negociados',
      'sales': '520',
      'img': 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?q=80&w=600&auto=format&fit=crop',
      'salesType': 'Al Detalle'
    },
    {
      'name': 'Nutrición Animal San Isidro',
      'rating': '4.7',
      'sector': 'Sector La Quebrada',
      'distance': 'A 11 km',
      'level': 'Nivel 3',
      'verified': true,
      'open': true,
      'closeTime': '17:00',
      'tags': 'Alimento Animal',
      'reviews': '150 reseñas de clientes',
      'traded': '780 productos negociados',
      'sales': '780',
      'img': 'https://images.unsplash.com/photo-1500595046743-cd271d694d30?q=80&w=600&auto=format&fit=crop',
      'salesType': 'Mayorista'
    },
    {
      'name': 'Carnes y Embutidos La Sierra',
      'rating': '4.8',
      'sector': 'Sector Los Pinos',
      'distance': 'A 7 km',
      'level': 'Nivel 4',
      'verified': true,
      'open': true,
      'closeTime': '19:30',
      'tags': 'Carnes y Embutidos',
      'reviews': '180 reseñas de clientes',
      'traded': '920 productos negociados',
      'sales': '920',
      'img': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?q=80&w=600&auto=format&fit=crop',
      'salesType': 'Al Detalle'
    },
    {
      'name': 'Apiario Los Robles',
      'rating': '4.6',
      'sector': 'Sector Las Colinas',
      'distance': 'A 9 km',
      'level': 'Nivel 2',
      'verified': false,
      'open': true,
      'closeTime': '17:00',
      'tags': 'Otros',
      'reviews': '64 reseñas de clientes',
      'traded': '310 productos negociados',
      'sales': '310',
      'img': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=600&auto=format&fit=crop',
      'salesType': 'Al Detalle'
    }
  ];

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'Frutas y verduras':
        return Icons.eco_rounded;
      case 'Cereales y granos':
        return Icons.grain_rounded;
      case 'Alimento Animal':
        return Icons.pets_rounded;
      case 'Semillas':
        return Icons.spa_rounded;
      case 'Lacteos':
        return Icons.local_drink_rounded;
      case 'Huevos':
        return Icons.egg_outlined;
      case 'Carnes y Embutidos':
        return Icons.kebab_dining_rounded;
      case 'Otros':
        return Icons.category_outlined;
      default:
        return Icons.apps_rounded;
    }
  }

  String _removeDiacritics(String str) {
    return str
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U');
  }

  bool _matchesSpecialty(String providerTags, String selectedSpecialty) {
    if (selectedSpecialty == 'Todas') return true;
    final pClean = _removeDiacritics(providerTags.trim().toLowerCase());
    final sClean = _removeDiacritics(selectedSpecialty.trim().toLowerCase());

    if (pClean == sClean) return true;
    if (pClean.contains(sClean) || sClean.contains(pClean)) return true;

    if (sClean.contains('fruta') && (pClean.contains('fruta') || pClean.contains('verdura'))) return true;
    if (sClean.contains('lacteo') && (pClean.contains('lacteo') || pClean.contains('queso'))) return true;
    if (sClean.contains('huevo') && (pClean.contains('huevo') || pClean.contains('ave'))) return true;
    if (sClean.contains('cereal') && (pClean.contains('cereal') || pClean.contains('grano'))) return true;
    if (sClean.contains('animal') && (pClean.contains('animal') || pClean.contains('forraje'))) return true;
    if (sClean.contains('semilla') && pClean.contains('semilla')) return true;
    if (sClean.contains('carne') && (pClean.contains('carne') || pClean.contains('embutido'))) return true;
    if (sClean == 'otros') return pClean.contains('miel') || pClean.contains('otro') || pClean.contains('planta');

    return false;
  }

  List<Map<String, dynamic>> get filteredProviders {
    return providers.where((provider) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final name = (provider['name'] ?? '').toString().toLowerCase();
        final tags = (provider['tags'] ?? '').toString().toLowerCase();
        final sector = (provider['sector'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchQuery) &&
            !tags.contains(_searchQuery) &&
            !sector.contains(_searchQuery)) {
          return false;
        }
      }

      // 2. Specialty Dropdown Filter
      if (_selectedSpecialty != 'Todas') {
        final tags = (provider['tags'] ?? '').toString();
        if (!_matchesSpecialty(tags, _selectedSpecialty)) {
          return false;
        }
      }

      // 3. Quick Chips Filters
      final distStr = provider['distance'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final dist = int.tryParse(distStr) ?? 0;

      // Chip 0: Cercanos (<= 10km)
      if (selectedChips.contains(0) && dist > 10) return false;

      // Chip 1: Mejor Valorados (>= 4.8)
      if (selectedChips.contains(1)) {
        final rating = double.tryParse(provider['rating'] ?? '0') ?? 0;
        if (rating < 4.8) return false;
      }

      // Chip 2: Verificados
      if (selectedChips.contains(2)) {
        if (provider['verified'] != true) return false;
      }

      // Chip 3: Orgánicos
      if (selectedChips.contains(3)) {
        final tags = (provider['tags'] ?? '').toLowerCase();
        if (!tags.contains('orgánic')) return false;
      }

      // Chip 4: Custom Distance Slider
      if (selectedChips.contains(4) && dist > _distance) return false;

      // 4. Horario de Atención Filter
      if (_isOpenNow && provider['open'] != true) return false;

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
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 100),
                children: [
                  // 1. Distance range slider (if chip 'Distancia' is active)
                  if (selectedChips.contains(4)) ...[
                    _buildDistanceSlider(theme, isDark),
                    const SizedBox(height: 12),
                  ],

                  // 2. Schedule Card
                  _buildScheduleCard(theme, isDark),
                  const SizedBox(height: 12),

                  // 3. Specialty Dropdown Filter Card
                  _buildSpecialtyCard(theme, isDark),
                  const SizedBox(height: 16),

                  // 4. Results counter & Active filters indicator
                  _buildResultsHeader(theme, isDark),
                  const SizedBox(height: 12),

                  // 5. Providers List or Empty State
                  if (filteredProviders.isEmpty)
                    _buildEmptyState(theme, isDark)
                  else
                    for (int i = 0; i < filteredProviders.length; i++) ...[
                      _buildProviderCard(theme, isDark, filteredProviders[i]),
                      if (i < filteredProviders.length - 1) const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
        border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search, color: theme.colorScheme.primary, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar proveedor...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey[800] : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          chips[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[200] : Colors.grey[700]),
                            fontSize: 13,
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
        ],
      ),
    );
  }

  Widget _buildDistanceSlider(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rango de búsqueda',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[200] : Colors.grey[700]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hasta ${_distance.toInt()} km',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
    );
  }

  Widget _buildScheduleCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Horario de Atención',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.grey[200] : Colors.grey[700]),
              ),
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
                      border: Border.all(
                        color: _isOpenNow ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Abierto ahora',
                      style: TextStyle(
                        color: _isOpenNow ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      border: Border.all(
                        color: !_isOpenNow ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Cualquier horario',
                      style: TextStyle(
                        color: !_isOpenNow ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(ThemeData theme, bool isDark) {
    final bool hasActiveFilter = _selectedSpecialty != 'Todas';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasActiveFilter
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          width: hasActiveFilter ? 1.5 : 1.0,
        ),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Especialidad del Proveedor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.grey[200] : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasActiveFilter) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '1 activa',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecialty = 'Todas';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 12, color: Colors.red),
                        SizedBox(width: 2),
                        Text(
                          'Quitar',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16251E) : const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasActiveFilter
                    ? theme.colorScheme.primary
                    : (isDark ? const Color(0xFF2E4E41) : const Color(0xFFDCE7DF)),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSpecialty,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                dropdownColor: isDark ? const Color(0xFF1E2E27) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
                items: specialties.map((String specialty) {
                  final isAll = specialty == 'Todas';
                  final isSelected = specialty == _selectedSpecialty;
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Row(
                      children: [
                        Icon(
                          _getSpecialtyIcon(specialty),
                          size: 16,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAll ? 'Todas las especialidades' : specialty,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.grey[200] : const Color(0xFF1E293B)),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSpecialty = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(ThemeData theme, bool isDark) {
    final count = filteredProviders.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$count ${count == 1 ? 'proveedor disponible' : 'proveedores disponibles'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_selectedSpecialty != 'Todas' || _searchQuery.isNotEmpty || selectedChips.length > 1) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedSpecialty = 'Todas';
                selectedChips = {0};
                _isOpenNow = true;
              });
            },
            child: Text(
              'Restablecer filtros',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 34,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay proveedores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[200] : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron resultados para los filtros seleccionados.\nIntenta cambiar la especialidad o ampliar el horario.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedSpecialty = 'Todas';
                  selectedChips = {0};
                  _isOpenNow = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Restablecer filtros', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(ThemeData theme, bool isDark, Map<String, dynamic> provider) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
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
                              child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
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
                                  child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
                                );
                              },
                            )
                          : Container(
                              height: 180,
                              width: double.infinity,
                              color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                              child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
                            )))
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1a2f26) : const Color(0xFFebefea),
                      child: Icon(Icons.storefront, size: 50, color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF285E44)),
                    ),
              ),
              if (provider['verified'])
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f172a).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
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
                        color: Colors.orange.withValues(alpha: 0.1),
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
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider['open'] == true ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider['open'] == true ? 'ABIERTO AHORA' : 'CERRADO',
                      style: TextStyle(
                        color: provider['open'] == true ? Colors.green : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• Cierra ${provider['closeTime']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    if (provider['level'] != null)
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
                              provider['level'],
                              style: TextStyle(
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
                Row(
                  children: [
                    Icon(Icons.handshake, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        provider['traded'] ?? '0 productos negociados',
                        style: TextStyle(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        provider['reviews'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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
