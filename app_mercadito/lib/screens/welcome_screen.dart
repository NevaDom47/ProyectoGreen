import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bouncing_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Bienvenido a\nEl Mercadito',
      'subtitle':
          'Nos alegra tenerte aquí. Conectamos directamente el campo y la agricultura con tu mesa o negocio.',
      'image': 'assets/images/welcome_slide_1.jpg',
      'buttonText': 'Empezar',
      'fallbackIcon': 'storefront_rounded',
    },
    {
      'title': 'Descubre Cosechas\nFrescas y Locales',
      'subtitle':
          'Precios justos, productos 100% dominicanos y acuerdos transparentes en tiempo real sin intermediarios.',
      'image': 'assets/images/welcome_slide_2.jpg',
      'buttonText': 'Continuar',
      'fallbackIcon': 'agriculture_rounded',
    },
    {
      'title': 'Conéctate como\nComprador o Proveedor',
      'subtitle':
          'Elige tu rol para comprar productos agrícolas de primera calidad o vender cosechas y expandir tu producción.',
      'buttonText': 'Seleccionar mi Rol',
      'image': 'assets/images/welcome_slide_3.jpg',
      'fallbackIcon': 'diversity_3_rounded',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    HapticFeedback.lightImpact();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToSelectRole();
    }
  }

  void _goToSelectRole() {
    HapticFeedback.mediumImpact();
    // Navigates directly to the role selection screen ("¿Cómo quieres participar?")
    context.go('/select-role');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Organic soft sage palette inspired by the design reference
    final bgColor = isDark ? const Color(0xFF101815) : const Color(0xFFF3F7F4);
    final cardBg = isDark ? const Color(0xFF1A2520) : Colors.white;
    final primaryForestGreen = isDark ? const Color(0xFF8BD8B2) : const Color(0xFF285E44);
    final buttonColor = isDark ? const Color(0xFF8BD8B2) : const Color(0xFF4A6856);
    final buttonTextColor = isDark ? const Color(0xFF003824) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF1B3828);
    final textMuted = isDark ? const Color(0xFF90A397) : const Color(0xFF5A7264);
    final indicatorInactive = isDark ? const Color(0xFF2D3C34) : const Color(0xFFCFDDD5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip ("Saltar") action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back arrow if not on first page
                  if (_currentPage > 0)
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: primaryForestGreen),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logos/logo_app_icon.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Skip Button
                  TextButton(
                    onPressed: _goToSelectRole,
                    style: TextButton.styleFrom(
                      foregroundColor: textMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Saltar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Pager Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),

                              // Image Container with Soft Rounded Corners & Natural Shadow
                              Container(
                                width: double.infinity,
                                height: 320,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    slide['image']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 320,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: primaryForestGreen.withValues(alpha: 0.12),
                                      child: Center(
                                        child: Icon(
                                          index == 0
                                              ? Icons.storefront_rounded
                                              : (index == 1
                                                  ? Icons.agriculture_rounded
                                                  : Icons.groups_rounded),
                                          size: 80,
                                          color: primaryForestGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Slide Title
                              Text(
                                slide['title']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 14),

                              // Slide Subtitle
                              Text(
                                slide['subtitle']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: textMuted,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Page Indicator & Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Action Pill Button
                    BouncingButton(
                      onTap: _onNextPressed,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withValues(alpha: isDark ? 0.35 : 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _slides[_currentPage]['buttonText']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Modern Capsule / Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = _currentPage == index;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8,
                            width: isActive ? 28 : 10,
                            decoration: BoxDecoration(
                              color: isActive ? primaryForestGreen : indicatorInactive,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        );
                      }),
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
}
