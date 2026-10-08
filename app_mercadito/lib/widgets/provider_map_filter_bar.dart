import 'package:flutter/material.dart';
import '../models/provider_map_item.dart';

class ProviderMapFilterBar extends StatelessWidget {
  final ProviderMapFilter currentFilter;
  final int matchingCount;
  final ValueChanged<ProviderMapFilter> onFilterChanged;
  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleList;

  const ProviderMapFilterBar({
    super.key,
    required this.currentFilter,
    required this.matchingCount,
    required this.onFilterChanged,
    required this.searchController,
    required this.onClearSearch,
    required this.onToggleList,
  });

  static const List<String> availableSpecialties = [
    'Todas',
    'Frutas y verduras',
    'Cereales y granos',
    'Alimento Animal',
    'Semillas',
    'Lacteos',
    'Huevos',
    'Carnes y Embutidos',
    'Otros',
  ];

  static const List<String> availableSalesTypes = [
    'Todos',
    'Mayorista',
    'Al Detalle',
    'Ambos',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const brandPrimary = Color(0xFF285E44);
    const brandAccent = Color(0xFFA5C2B7);
    final surfaceColor = isDark ? const Color(0xFF16251F) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF1E293B);
    final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF243B32) : const Color(0xFFE2E8F0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Search Box with List toggle & Back button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: brandPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    onFilterChanged(currentFilter.copyWith(searchQuery: val));
                  },
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, provincia o producto...',
                    hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, size: 18, color: subtextColor),
                  onPressed: onClearSearch,
                ),
              Container(
                height: 24,
                width: 1,
                color: borderColor,
              ),
              // Toggle to List View button
              IconButton(
                icon: const Icon(Icons.list_alt_rounded, color: brandPrimary),
                tooltip: 'Ver como lista',
                onPressed: onToggleList,
              ),
            ],
          ),
        ),

        // 2. Horizontal Scrolling Filter Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: brandPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$matchingCount en RD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Chip: Verificados
              _buildFilterToggleChip(
                label: 'Verificados',
                icon: Icons.verified_user_outlined,
                isActive: currentFilter.onlyVerified,
                onTap: () {
                  onFilterChanged(currentFilter.copyWith(
                    onlyVerified: !currentFilter.onlyVerified,
                  ));
                },
                brandPrimary: brandPrimary,
                brandAccent: brandAccent,
                surfaceColor: surfaceColor,
                textColor: textColor,
                borderColor: borderColor,
              ),
              const SizedBox(width: 8),

              // Chip: Abierto ahora
              _buildFilterToggleChip(
                label: 'Abierto ahora',
                icon: Icons.access_time_rounded,
                isActive: currentFilter.onlyOpen,
                onTap: () {
                  onFilterChanged(currentFilter.copyWith(
                    onlyOpen: !currentFilter.onlyOpen,
                  ));
                },
                brandPrimary: brandPrimary,
                brandAccent: brandAccent,
                surfaceColor: surfaceColor,
                textColor: textColor,
                borderColor: borderColor,
              ),
              const SizedBox(width: 8),

              // Chip: Especialidad selector
              _buildDropdownFilterChip(
                label: currentFilter.specialty == 'Todas'
                    ? 'Especialidad'
                    : currentFilter.specialty,
                isActive: currentFilter.specialty != 'Todas',
                icon: Icons.category_outlined,
                options: availableSpecialties,
                onSelected: (val) {
                  onFilterChanged(currentFilter.copyWith(specialty: val));
                },
                context: context,
                brandPrimary: brandPrimary,
                surfaceColor: surfaceColor,
                textColor: textColor,
                borderColor: borderColor,
              ),
              const SizedBox(width: 8),

              // Chip: Tipo de Venta selector
              _buildDropdownFilterChip(
                label: currentFilter.salesType == 'Todos'
                    ? 'Tipo de venta'
                    : currentFilter.salesType,
                isActive: currentFilter.salesType != 'Todos',
                icon: Icons.store_mall_directory_outlined,
                options: availableSalesTypes,
                onSelected: (val) {
                  onFilterChanged(currentFilter.copyWith(salesType: val));
                },
                context: context,
                brandPrimary: brandPrimary,
                surfaceColor: surfaceColor,
                textColor: textColor,
                borderColor: borderColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToggleChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color brandPrimary,
    required Color brandAccent,
    required Color surfaceColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? brandPrimary : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? brandPrimary : borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : brandPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : textColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilterChip({
    required String label,
    required bool isActive,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String> onSelected,
    required BuildContext context,
    required Color brandPrimary,
    required Color surfaceColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) {
        return options.map((opt) {
          return PopupMenuItem<String>(
            value: opt,
            child: Text(
              opt,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: opt == label ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? brandPrimary : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? brandPrimary : borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : brandPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : textColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive ? Colors.white : textColor,
            ),
          ],
        ),
      ),
    );
  }
}
