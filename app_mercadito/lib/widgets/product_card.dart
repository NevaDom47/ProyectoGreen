import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String priceUnit;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.priceUnit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14181F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF262D38)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: isDark ? const Color(0xFF1C222B) : Colors.grey[300],
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: isDark ? const Color(0xFF6B7280) : Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF3F4F6) : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$price',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF3F4F6) : theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatUnit(priceUnit),
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      default:
        // Capitalize first letter
        if (raw.isNotEmpty) {
          raw = raw[0].toUpperCase() + raw.substring(1);
        }
        return 'Por $raw';
    }
  }
}
