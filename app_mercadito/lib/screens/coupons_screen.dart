import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; 
import '../widgets/coupon_card.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        // Colors from Tailwind config
        final bgColor = isDark ? const Color(0xFF0d1a15) : const Color(0xFFf8fdfb);
        final primaryColor = const Color(0xFF016142);
        final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white; 
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
        final borderColor = primaryColor.withOpacity(0.1);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Mis Cupones',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Public Sans',
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline, color: primaryColor),
                onPressed: () {},
              )
            ],
          ),
          body: Column(
            children: [
              // Search / Code Entry
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.confirmation_number, color: primaryColor.withOpacity(0.6), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingresar código de cupón',
                            hintStyle: TextStyle(color: subtextColor.withOpacity(0.6), fontSize: 14),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                      ),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Canjear',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: primaryColor, width: 3)),
                          ),
                          child: Text(
                            'Activos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.transparent, width: 3)),
                          ),
                          child: Text(
                            'Historial',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subtextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Coupon List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CouponCard(
                      icon: Icons.local_grocery_store,
                      category: 'FRUTAS & VERDURAS',
                      discount: '15% OFF',
                      badge: 'NUEVO',
                      condition: 'Compra mínima \$20.000',
                      code: 'VERDE15',
                      expiry: '30 Oct 2023',
                      buttonLabel: 'Copiar',
                      buttonIcon: Icons.content_copy,
                      bgColor: bgColor,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      borderColor: borderColor,
                      onButtonTap: () {
                        Clipboard.setData(const ClipboardData(text: 'VERDE15'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código VERDE15 copiado al portapapeles', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF00462f), duration: Duration(seconds: 2))
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CouponCard(
                      icon: Icons.eco,
                      category: 'ORGÁNICOS',
                      discount: '\$5.000 DTO',
                      badge: null,
                      condition: 'En toda la tienda',
                      code: 'ORGANICOS',
                      expiry: '15 Nov 2023',
                      buttonLabel: 'Copiar',
                      buttonIcon: Icons.content_copy,
                      bgColor: bgColor,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      borderColor: borderColor,
                      onButtonTap: () {
                        Clipboard.setData(const ClipboardData(text: 'ORGANICOS'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código ORGANICOS copiado al portapapeles', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF00462f), duration: Duration(seconds: 2))
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CouponCard(
                      icon: Icons.bakery_dining,
                      category: 'PANADERÍA',
                      discount: '2x1',
                      badge: null,
                      condition: 'Pan artesanal',
                      code: 'PAN2X1',
                      expiry: 'Mañana',
                      buttonLabel: 'Ver más',
                      buttonIcon: null,
                      bgColor: bgColor,
                      surfaceColor: surfaceColor,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      borderColor: borderColor,
                      isFaded: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

}
