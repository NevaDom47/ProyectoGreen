import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        // Colors from the provided Tailwind config
        final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
        final primaryColor = const Color(0xFF016042);
        final surfaceColor = isDark ? const Color(0xFF1e293b).withValues(alpha: 0.5) : Colors.white;
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
        final borderColor = primaryColor.withValues(alpha: 0.1);

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
              'Políticas Legales',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.gavel, color: primaryColor, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Última actualización: 24 de mayo de 2024',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Accordions
                _buildPolicyAccordion(
                  title: 'Términos y Condiciones',
                  icon: Icons.description,
                  content: 'Bienvenido a El Mercadito. Al utilizar nuestra aplicación, usted acepta cumplir con estos términos. El uso de la plataforma está destinado únicamente a mayores de edad con capacidad legal para contratar.\n\nNos reservamos el derecho de modificar o retirar servicios en cualquier momento. Usted es responsable de mantener la confidencialidad de su cuenta y contraseña.',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                _buildPolicyAccordion(
                  title: 'Política de Privacidad',
                  icon: Icons.lock,
                  content: 'En El Mercadito, la privacidad de sus datos es nuestra prioridad. Recopilamos información personal solo con el fin de mejorar su experiencia de compra y gestionar sus pedidos.\n\nSus datos no serán compartidos con terceros sin su consentimiento explícito, excepto cuando sea necesario para procesar pagos o realizar entregas.',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
                const SizedBox(height: 16),
                _buildPolicyAccordion(
                  title: 'Uso de Cookies',
                  icon: Icons.cookie,
                  content: 'Utilizamos cookies propias y de terceros para analizar el tráfico de la aplicación y recordar sus preferencias de navegación.\n\nPuede gestionar la configuración de cookies en los ajustes de su dispositivo móvil, aunque esto podría afectar la funcionalidad de algunas partes de la app.',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),

                const SizedBox(height: 40),

                // Footer Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¿Tienes alguna duda?',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si necesitas más información sobre nuestras políticas, contacta con nuestro equipo legal.',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          // Placeholder
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mail, color: primaryColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'legal@elmercadito.com',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPolicyAccordion({
    required String title,
    required IconData icon,
    required String content,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
    required Color textColor,
    required Color subtextColor,
    bool isExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          iconColor: primaryColor,
          collapsedIconColor: primaryColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
              child: Text(
                content,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
