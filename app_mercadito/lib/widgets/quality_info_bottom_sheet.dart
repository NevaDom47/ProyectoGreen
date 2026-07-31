import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QualityInfoBottomSheet extends StatelessWidget {
  final String quality;

  const QualityInfoBottomSheet({super.key, required this.quality});

  static const Map<String, dynamic> _qualityData = {
    'PRIMERA': {
      'title': 'Calidad Premium',
      'color': Color(0xFF00462F),
      'icon': Icons.workspace_premium,
      'description': 'Los productos de Primera Calidad son seleccionados a mano por nuestros agricultores bajo los más altos estándares de frescura, sabor y apariencia.',
      'points': [
        {'icon': Icons.eco, 'title': '100% Orgánicos', 'desc': 'Cultivados sin pesticidas ni químicos sintéticos.'},
        {'icon': Icons.wb_sunny, 'title': 'Cosechados el mismo día', 'desc': 'Garantía de máxima frescura desde la tierra a tu mesa.'},
        {'icon': Icons.diamond, 'title': 'Sin imperfecciones estéticas', 'desc': 'Selección rigurosa de forma, color y tamaño ideal.'},
        {'icon': Icons.verified_user, 'title': 'Origen certificado', 'desc': 'Trazabilidad completa hasta la finca productora.'},
      ]
    },
    'SEGUNDA': {
      'title': 'Segunda Calidad',
      'color': Color(0xFFF59E0B),
      'icon': Icons.eco,
      'description': 'Son productos frescos y nutritivos con pequeñas imperfecciones estéticas que no afectan su sabor ni calidad nutricional, a un precio más accesible.',
      'points': [
        {'icon': Icons.restaurant, 'title': 'Sabor Auténtico', 'desc': 'La misma frescura y valor nutricional garantizado.'},
        {'icon': Icons.check_circle, 'title': 'Pequeños Detalles Estéticos', 'desc': 'Manchas o formas irregulares naturales.'},
        {'icon': Icons.agriculture, 'title': 'Directo del Campo', 'desc': 'Apoyas a los productores reduciendo el desperdicio.'},
        {'icon': Icons.savings, 'title': 'Más Económicos', 'desc': 'Precios reducidos por variaciones visuales.'},
      ]
    },
    'TERCERA': {
      'title': 'Tercera Calidad',
      'color': Color(0xFFFC424D),
      'icon': Icons.warning,
      'description': 'Productos con imperfecciones estéticas o descartes que mantienen su valor nutricional, ideales para procesamiento o consumo inmediato a precios mínimos.',
      'points': [
        {'icon': Icons.visibility_off, 'title': 'Imperfecciones Visuales', 'desc': 'Manchas o formas irregulares.'},
        {'icon': Icons.sell, 'title': 'Precios de Liquidación', 'desc': 'El costo más bajo del mercado.'},
        {'icon': Icons.blender, 'title': 'Uso Recomendado', 'desc': 'Ideal para jugos, salsas o mermeladas.'},
        {'icon': Icons.recycling, 'title': 'Sostenibilidad', 'desc': 'Ayuda a reducir el desperdicio alimentario.'},
      ]
    }
  };

  @override
  Widget build(BuildContext context) {
    final String key = quality.toUpperCase().contains('PRIMERA') 
        ? 'PRIMERA' 
        : (quality.toUpperCase().contains('SEGUNDA') ? 'SEGUNDA' : 'TERCERA');
    
    final data = _qualityData[key];
    final Color mainColor = data['color'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final Color bgColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final Color surfaceColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFf1f4f0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF3f4943);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data['icon'], color: mainColor, size: 32),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            data['title'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            data['description'],
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: subTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Bento List
          Flexible(
            child: Column(
              children: (data['points'] as List).map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(point['icon'], color: mainColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                point['title'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                point['desc'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'ENTENDIDO',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
