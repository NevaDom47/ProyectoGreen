import 'dart:ui';
import 'package:flutter/material.dart';

Future<String?> showLocationSelector(BuildContext context) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar modal',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: const LocationSelectorModal(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0)
            .animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

class LocationSelectorModal extends StatefulWidget {
  const LocationSelectorModal({super.key});

  @override
  State<LocationSelectorModal> createState() => _LocationSelectorModalState();
}

class _LocationSelectorModalState extends State<LocationSelectorModal> {
  final List<String> _popularLocations = [
    'Santo Domingo',
    'Santiago',
    'La Vega',
    'Puerto Plata'
  ];

  List<String> _filteredLocations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLocations = _popularLocations;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredLocations = _popularLocations;
        } else {
          _filteredLocations = _popularLocations
              .where((loc) => loc.toLowerCase().contains(query))
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131c26) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1f2937) : const Color(0xFFf1f4f0);
    final iconBgColor = isDark ? const Color(0xFF374151) : const Color(0xFFe6e9e4);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 795),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona tu Ubicación',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF181d1a),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Encuentra los mejores productos cerca de ti.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF3f4943),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark ? Colors.grey[300] : const Color(0xFF3f4943),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Action Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop('Mi Ubicación Actual');
                      },
                      icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
                      label: const Text(
                        'USAR MI UBICACIÓN ACTUAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF016142),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: const Color(0xFF016142).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Busca tu ciudad o sector...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFFbec9c1), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[500] : const Color(0xFFbec9c1), size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'UBICACIONES POPULARES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[500] : const Color(0xFF6f7a73),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),

                    // List elements
                    if (_filteredLocations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No se encontraron ubicaciones.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      )
                    else
                      ..._filteredLocations.map(
                        (loc) => _buildLocationItem(loc, theme, isDark, iconBgColor, context),
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

  Widget _buildLocationItem(String title, ThemeData theme, bool isDark, Color iconBgColor, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(title);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF181d1a),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : const Color(0xFFbec9c1), size: 24),
          ],
        ),
      ),
    );
  }
}
