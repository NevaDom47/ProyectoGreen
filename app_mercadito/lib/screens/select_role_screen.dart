import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_session.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? _selectedRole; // 'comprador' or 'proveedor'

  // Standard theme colors matching Emerald Harvest guidelines
  static const Color _colorPrimary = Color(0xFF00462f);
  static const Color _colorBackground = Color(0xFFF7FAF5);
  static const Color _colorSurfaceCard = Colors.white;
  static const Color _colorOutlineVariant = Color(0xFFBEC9C1);
  static const Color _colorOnSurfaceVariant = Color(0xFF3F4943);
  static const Color _colorSecondaryContainerTint = Color(0xFFCAEAD7);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final actualBg = isDarkMode ? const Color(0xFF121814) : _colorBackground;
    final actualCardBg = isDarkMode ? const Color(0xFF1E2621) : _colorSurfaceCard;
    final actualTextVariant = isDarkMode ? const Color(0xFF90A397) : _colorOnSurfaceVariant;
    final actualPrimary = isDarkMode ? const Color(0xFF8BD8B2) : _colorPrimary;

    return Scaffold(
      backgroundColor: actualBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Title
                  Text(
                    '¿Cómo quieres participar?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: actualPrimary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Header Subtitle
                  Text(
                    'Elige tu rol para personalizar tu experiencia en el Mercadito.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: actualTextVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Cards layout (Row on wider screens, Column on portrait)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 550;
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Comprador Card
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildRoleCard(
                              roleId: 'comprador',
                              title: 'Comprador',
                              description:
                                  'Busca productos frescos directamente de la granja, negocia precios en tiempo real y recibe tu cosecha en casa.',
                              icon: Icons.shopping_basket_outlined,
                              isDarkMode: isDarkMode,
                              actualCardBg: actualCardBg,
                              actualPrimary: actualPrimary,
                              actualTextVariant: actualTextVariant,
                            ),
                          ),
                          if (isWide) const SizedBox(width: 24) else const SizedBox(height: 20),
                          // Proveedor Card
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildRoleCard(
                              roleId: 'proveedor',
                              title: 'Proveedor / Negociante',
                              description:
                                  'Publica tus cosechas, gestiona negociaciones con compradores y accede a herramientas de análisis para hacer crecer tu negocio.',
                              icon: Icons.agriculture_outlined,
                              isDarkMode: isDarkMode,
                              actualCardBg: actualCardBg,
                              actualPrimary: actualPrimary,
                              actualTextVariant: actualTextVariant,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Confirm Button
                  _buildConfirmButton(actualPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String description,
    required IconData icon,
    required bool isDarkMode,
    required Color actualCardBg,
    required Color actualPrimary,
    required Color actualTextVariant,
  }) {
    final isSelected = _selectedRole == roleId;

    // Harmonious container variables based on selection status
    final cardBorderColor = isSelected
        ? actualPrimary
        : (isDarkMode ? const Color(0xFF3A4740) : _colorOutlineVariant);
    
    final cardBgColor = isSelected
        ? (isDarkMode
            ? const Color(0xFF1B2C24)
            : _colorSecondaryContainerTint.withOpacity(0.25))
        : actualCardBg;

    final shadowColor = isSelected
        ? actualPrimary.withOpacity(isDarkMode ? 0.15 : 0.1)
        : Colors.black.withOpacity(isDarkMode ? 0.1 : 0.03);

    final shadowBlur = isSelected ? 16.0 : 8.0;
    final shadowOffset = isSelected ? const Offset(0, 8) : const Offset(0, 4);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = roleId;
          });
        },
        child: AnimatedScale(
          scale: isSelected ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cardBorderColor,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: shadowBlur,
                  offset: shadowOffset,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Circle Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? actualPrimary.withOpacity(0.15)
                        : (isDarkMode ? const Color(0xFF27302B) : const Color(0xFFE6E9E4)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected ? actualPrimary : actualTextVariant,
                  ),
                ),
                const SizedBox(height: 18),
                // Card Title
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? actualPrimary : (isDarkMode ? Colors.white : _colorPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                // Card Description
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: actualTextVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Radio / Check Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? actualPrimary : (isDarkMode ? const Color(0xFF4C5B52) : _colorOutlineVariant),
                      width: 2.0,
                    ),
                    color: isSelected ? actualPrimary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(Color actualPrimary) {
    final bool isEnabled = _selectedRole != null;

    final btnBg = isEnabled
        ? actualPrimary
        : const Color(0xFFBEC9C1); // Neutral/grey border matching CSS disabled

    return AnimatedScale(
      scale: isEnabled ? 1.0 : 0.96,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: actualPrimary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  // Set active user role inside simulated session
                  UserSession.selectedRole = _selectedRole;
                  
                  // Show elegant confirmation alert
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            _selectedRole == 'comprador'
                                ? 'Rol de Comprador seleccionado. Comencemos tu perfil.'
                                : 'Rol de Proveedor / Negociante seleccionado. Comencemos tu perfil.',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: actualPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  // Proceed directly to the main feed or onboarding
                  if (_selectedRole == 'comprador') {
                    context.go('/buyer-onboarding');
                  } else {
                    context.go('/provider-onboarding');
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnBg,
            disabledBackgroundColor: const Color(0xFFBEC9C1),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999), // Perfect rounded full pill
            ),
            elevation: 0,
          ),
          child: Text(
            'CONTINUAR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0, // wide tracking-widest
            ),
          ),
        ),
      ),
    );
  }
}
