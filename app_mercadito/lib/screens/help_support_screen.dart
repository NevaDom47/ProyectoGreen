import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Colores basados en el HTML proporcionado
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final surfaceColor = isDark ? const Color(0xFF1e293b) : Colors.white; // slate-800 o blanco
    final primaryColor = const Color(0xFF016042);
    final textHeaderColor = isDark ? const Color(0xFFf1f5f9) : const Color(0xFF0f172a); // slate-100 o slate-900
    final subtextColor = isDark ? const Color(0xFF64748b) : const Color(0xFF64748b); // slate-500

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ayuda y Soporte',
          style: TextStyle(
            color: textHeaderColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid de Categorías (Botones cuadrados)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORÍAS DE AYUDA',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildCategoryCard(context, 'Preguntas Frecuentes', Icons.quiz, primaryColor, surfaceColor, isDark),
                        _buildCategoryCard(context, 'Guía para Compradores', Icons.shopping_basket, primaryColor, surfaceColor, isDark),
                        _buildCategoryCard(context, 'Guía para Vendedores', Icons.storefront, primaryColor, surfaceColor, isDark),
                        _buildCategoryCard(context, 'Seguridad y Denuncias', Icons.gpp_maybe, primaryColor, surfaceColor, isDark),
                      ],
                    ),
                  ],
                ),
              ),

              // Sección FAQ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSULTAS POPULARES',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFaqTile(
                      '¿Cómo negociar un precio?',
                      'Puedes usar la función de "Oferta" directamente en el chat con el vendedor para proponer un precio justo basado en el volumen de compra.',
                      primaryColor,
                      surfaceColor,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFaqTile(
                      '¿Cómo rastrear mi pedido?',
                      'En la sección "Mis Compras", selecciona el pedido activo para ver la ubicación en tiempo real del transportista asignado.',
                      primaryColor,
                      surfaceColor,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildFaqTile(
                      'Métodos de pago aceptados',
                      'Aceptamos transferencias bancarias, tarjetas de crédito, débito y pagos en efectivo a través de puntos autorizados.',
                      primaryColor,
                      surfaceColor,
                      isDark,
                    ),
                  ],
                ),
              ),

              // Tarjeta de Contacto / Soporte
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Brillo superior derecho (como en CSS)
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿Necesitas hablar con nosotros?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nuestro equipo de soporte técnico está disponible 24/7 para ayudarte con lo que necesites.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.forum, size: 20),
                              label: const Text('Chat en vivo', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Redes Sociales Bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Síguenos en nuestras redes',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.facebook, color: subtextColor),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined, color: subtextColor), // Proxy instagram
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.share, color: subtextColor),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color primaryColor, Color surfaceColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, Color primaryColor, Color surfaceColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: primaryColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                answer,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94a3b8) : const Color(0xFF475569), // slate-400 / slate-600
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
