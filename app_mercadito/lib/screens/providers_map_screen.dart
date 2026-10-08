import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../models/provider_map_item.dart';
import '../repositories/provider_map_repository.dart';
import '../widgets/provider_map_card.dart';
import '../widgets/provider_map_filter_bar.dart';
import '../widgets/provider_map_pin.dart';

class ProvidersMapScreen extends StatefulWidget {
  final IProviderMapRepository repository;

  ProvidersMapScreen({super.key, IProviderMapRepository? repository})
      : repository = repository ?? ProviderMapRepository();

  @override
  State<ProvidersMapScreen> createState() => _ProvidersMapScreenState();
}

class _ProvidersMapScreenState extends State<ProvidersMapScreen> {
  static const LatLng _dominicanRepublicCenter = LatLng(18.7357, -70.1627);
  static const double _defaultZoom = 8.2;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  ProviderMapFilter _currentFilter = const ProviderMapFilter();
  List<ProviderMapItem> _providers = [];
  ProviderMapItem? _selectedProvider;
  double _currentZoom = _defaultZoom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    final items = await widget.repository.getProviders(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _providers = items;
      _isLoading = false;
      // If selected provider no longer matches filter, clear selection
      if (_selectedProvider != null &&
          !items.any((item) => item.id == _selectedProvider!.id)) {
        _selectedProvider = null;
      }
    });
  }

  void _onFilterChanged(ProviderMapFilter newFilter) {
    setState(() => _currentFilter = newFilter);
    _loadProviders();
  }

  void _selectProvider(ProviderMapItem provider) {
    setState(() {
      _selectedProvider = provider;
      _currentZoom = 12.5;
    });
    _mapController.move(provider.coordinates, 12.5);
  }

  void _recenterDominicanRepublic() {
    _mapController.move(_dominicanRepublicCenter, _defaultZoom);
    setState(() {
      _selectedProvider = null;
      _currentZoom = _defaultZoom;
    });
  }

  void _zoomIn() {
    final nextZoom = (_currentZoom + 1.0).clamp(6.5, 18.0);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _zoomOut() {
    final nextZoom = (_currentZoom - 1.0).clamp(6.5, 18.0);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _navigateToProviderProfile(ProviderMapItem provider) {
    context.push('/provider', extra: provider.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const brandPrimary = Color(0xFF285E44);
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

    return Scaffold(
      body: Stack(
        children: [
          // 1. Interactive Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _dominicanRepublicCenter,
              initialZoom: _defaultZoom,
              minZoom: 6.5,
              maxZoom: 18.0,
              onPositionChanged: (camera, hasGesture) {
                final oldTier = ProviderMapPin.getZoomTier(_currentZoom);
                final newTier = ProviderMapPin.getZoomTier(camera.zoom);
                if (oldTier != newTier || (camera.zoom - _currentZoom).abs() >= 0.35) {
                  setState(() {
                    _currentZoom = camera.zoom;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.mercadito.app',
                tileBuilder: (context, tileWidget, tile) {
                  return tileWidget;
                },
              ),
              MarkerLayer(
                markers: _providers.map((p) {
                  final isSelected = _selectedProvider?.id == p.id;
                  final tier = ProviderMapPin.getZoomTier(_currentZoom);
                  final showDetailed = isSelected || tier == 2;
                  final showPill = isSelected || tier >= 1;

                  final double markerWidth = showDetailed ? 210 : (showPill ? 170 : 48);
                  final double markerHeight = showDetailed ? 104 : (showPill ? 82 : 48);

                  return Marker(
                    point: p.coordinates,
                    width: markerWidth,
                    height: markerHeight,
                    alignment: Alignment.bottomCenter,
                    child: ProviderMapPin(
                      provider: p,
                      isSelected: isSelected,
                      currentZoom: _currentZoom,
                      onTap: () => _selectProvider(p),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Top Floating Filters & Search Bar
          SafeArea(
            child: ProviderMapFilterBar(
              currentFilter: _currentFilter,
              matchingCount: _providers.length,
              searchController: _searchController,
              onFilterChanged: _onFilterChanged,
              onClearSearch: () {
                _searchController.clear();
                _onFilterChanged(_currentFilter.copyWith(searchQuery: ''));
              },
              onToggleList: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/providers');
                }
              },
            ),
          ),

          // 3. Floating Map Controls (Zoom in/out, Recenter)
          Positioned(
            right: 16,
            bottom: _selectedProvider != null ? 220 : 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recentrar República Dominicana',
                  onTap: _recenterDominicanRepublic,
                  brandPrimary: brandPrimary,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Acercar',
                  onTap: _zoomIn,
                  brandPrimary: brandPrimary,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _buildFloatingButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Alejar',
                  onTap: _zoomOut,
                  brandPrimary: brandPrimary,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 4. Loading Indicator
          if (_isLoading)
            const Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: brandPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 5. Empty State Banner
          if (!_isLoading && _providers.isEmpty)
            Positioned(
              top: 140,
              left: 32,
              right: 32,
              child: Card(
                elevation: 4,
                color: isDark ? const Color(0xFF16251F) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: brandPrimary, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'No hay proveedores en RD con los filtros aplicados',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _onFilterChanged(const ProviderMapFilter());
                        },
                        child: const Text('Limpiar', style: TextStyle(color: brandPrimary)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. Selected Provider Quick Details Bottom Card
          if (_selectedProvider != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: ProviderMapCard(
                  provider: _selectedProvider!,
                  onViewProfile: () => _navigateToProviderProfile(_selectedProvider!),
                  onClose: () => setState(() => _selectedProvider = null),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color brandPrimary,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251F) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: brandPrimary, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
}
