import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_session.dart';
import '../data/countries_states.dart';


class CountryPhoneCode {
  final String isoCode;
  final String code;
  final String name;

  const CountryPhoneCode({
    required this.isoCode,
    required this.code,
    required this.name,
  });
}

class BuyerOnboardingScreen extends StatefulWidget {
  const BuyerOnboardingScreen({super.key});

  @override
  State<BuyerOnboardingScreen> createState() => _BuyerOnboardingScreenState();
}

class _BuyerOnboardingScreenState extends State<BuyerOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0, 1, 2 for Steps 1, 2, 3

  // Theme Constants
  static const Color _colorPrimary = Color(0xFF00462f);
  static const Color _colorBackground = Color(0xFFF7FAF5);
  static const Color _colorSurfaceCard = Colors.white;
  static const Color _colorOutlineVariant = Color(0xFFBEC9C1);
  static const Color _colorOnSurfaceVariant = Color(0xFF3F4943);

  // Form Field Keys & Controllers
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();

  static const List<CountryPhoneCode> _phoneCodes = [
    CountryPhoneCode(isoCode: 'mx', code: '+52', name: 'México'),
    CountryPhoneCode(isoCode: 'co', code: '+57', name: 'Colombia'),
    CountryPhoneCode(isoCode: 'ar', code: '+54', name: 'Argentina'),
    CountryPhoneCode(isoCode: 'pe', code: '+51', name: 'Perú'),
    CountryPhoneCode(isoCode: 'cl', code: '+56', name: 'Chile'),
    CountryPhoneCode(isoCode: 'ec', code: '+593', name: 'Ecuador'),
    CountryPhoneCode(isoCode: 've', code: '+58', name: 'Venezuela'),
    CountryPhoneCode(isoCode: 'gt', code: '+502', name: 'Guatemala'),
    CountryPhoneCode(isoCode: 'sv', code: '+503', name: 'El Salvador'),
    CountryPhoneCode(isoCode: 'hn', code: '+504', name: 'Honduras'),
    CountryPhoneCode(isoCode: 'ni', code: '+505', name: 'Nicaragua'),
    CountryPhoneCode(isoCode: 'cr', code: '+506', name: 'Costa Rica'),
    CountryPhoneCode(isoCode: 'pa', code: '+507', name: 'Panamá'),
    CountryPhoneCode(isoCode: 'bo', code: '+591', name: 'Bolivia'),
    CountryPhoneCode(isoCode: 'py', code: '+595', name: 'Paraguay'),
    CountryPhoneCode(isoCode: 'uy', code: '+598', name: 'Uruguay'),
    CountryPhoneCode(isoCode: 'do', code: '+1', name: 'Rep. Dominicana'),
    CountryPhoneCode(isoCode: 'pr', code: '+1', name: 'Puerto Rico'),
    CountryPhoneCode(isoCode: 'cu', code: '+53', name: 'Cuba'),
    CountryPhoneCode(isoCode: 'us', code: '+1', name: 'EE.UU.'),
    CountryPhoneCode(isoCode: 'ca', code: '+1', name: 'Canadá'),
    CountryPhoneCode(isoCode: 'br', code: '+55', name: 'Brasil'),
    CountryPhoneCode(isoCode: 'es', code: '+34', name: 'España'),
  ];

  late CountryPhoneCode _selectedPhoneCode = _phoneCodes.first; // Default to México

  // Step 2 variables
  String? _selectedCountry;
  String? _selectedState;

  // Step 3 variables
  String _selectedAvatarUrl = 'assets/images/Foto sin perfil.png';

  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
          _selectedAvatarUrl = image.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _showSearchablePicker({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E2220) : Colors.white;
            final primary = isDark ? const Color(0xFF8BD8B2) : _colorPrimary;
            final actualTextVariant = isDark ? const Color(0xFF90A397) : _colorOnSurfaceVariant;
            
            String query = '';

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (context, setInnerState) {
                    final filtered = options
                        .where((opt) => opt.toLowerCase().contains(query.toLowerCase()))
                        .toList();

                    return Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[700] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              onChanged: (val) {
                                setInnerState(() {
                                  query = val;
                                });
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                hintStyle: GoogleFonts.plusJakartaSans(color: actualTextVariant),
                                prefixIcon: Icon(Icons.search, color: primary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: primary, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      'No se encontraron resultados',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: actualTextVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final option = filtered[index];
                                      final isSelected = option == selectedValue;
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: isDark ? const Color(0xFF2C3530) : const Color(0xFFE8ECE5),
                                                width: 1,
                                              ),
                                            ),
                                            color: isSelected
                                                ? (isDark ? const Color(0xFF14241C) : const Color(0xFFEAF2E8))
                                                : Colors.transparent,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                    color: isSelected
                                                        ? (isDark ? Colors.white : primary)
                                                        : (isDark ? Colors.white70 : Colors.black87),
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle, color: isDark ? Colors.white : primary, size: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E2220) : Colors.white;
            final primary = const Color(0xFF00462f);
            
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Selecciona tu país',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _phoneCodes.length,
                          itemBuilder: (context, index) {
                            final country = _phoneCodes[index];
                            final isSelected = country.isoCode == _selectedPhoneCode.isoCode;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPhoneCode = country;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark ? const Color(0xFF2C3530) : const Color(0xFFE8ECE5),
                                      width: 1,
                                    ),
                                  ),
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF14241C) : const Color(0xFFEAF2E8))
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.asset(
                                        'assets/images/${country.isoCode}.png',
                                        width: 32,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.flag, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? Colors.white : primary)
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      country.code,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? (isDark ? Colors.white : primary)
                                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 12),
                                      Icon(Icons.check_circle, color: isDark ? Colors.white : primary, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) {
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedCountry == null || _selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Por favor seleccione su país y provincia o estado.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Go back to role selection
      context.go('/select-role');
    }
  }

  void _completeOnboarding() {
    // Save details to session
    UserSession.fullName = _nameController.text.trim();
    UserSession.phone = '${_selectedPhoneCode.code} ${_phoneController.text.trim()}';
    UserSession.country = _selectedCountry;
    UserSession.state = _selectedState;
    UserSession.streetAddress = '';
    UserSession.profilePictureUrl = _pickedImagePath ?? _selectedAvatarUrl;
    UserSession.isBuyerOnboarded = true;

    // Show premium confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              '¡Perfil completado con éxito!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Proceed to feed
    context.go('/home');
  }

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
        child: Column(
          children: [
            // Onboarding Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: actualPrimary),
                    onPressed: _prevStep,
                  ),
                  Column(
                    children: [
                      Text(
                        'Paso ${_currentStep + 1} de 3',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: actualPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF27302B) : const Color(0xFFE6E9E4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 120 * ((_currentStep + 1) / 3),
                              height: 4,
                              decoration: BoxDecoration(
                                color: actualPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48), // Balancing spacer
                ],
              ),
            ),

            // Page Slider
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Managed through buttons
                children: [
                  _buildStep1(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep2(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep3(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                ],
              ),
            ),

            // Fixed Bottom Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actualPrimary,
                    foregroundColor: isDarkMode ? const Color(0xFF121814) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 2 ? 'COMPLETAR PERFIL' : 'CONTINUAR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == 2 ? Icons.check_circle_outline : Icons.arrow_forward,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Datos Personales
  Widget _buildStep1(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Perfil de Comprador',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Comencemos con tus datos esenciales para mejorar tu experiencia en el mercado.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          // Form Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Form(
              key: _formKeyStep1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, color: primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '1. Información Personal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  Text(
                    'Nombre Completo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Ana García',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa tu nombre completo.';
                      }
                      if (val.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  Text(
                    'Teléfono',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: '55 1234 5678',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _showCountryPicker,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Image.asset(
                                      'assets/images/${_selectedPhoneCode.isoCode}.png',
                                      width: 24,
                                      height: 16,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedPhoneCode.code,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa tu número de teléfono.';
                      }
                      if (val.trim().length < 8) {
                        return 'El teléfono debe tener al menos 8 dígitos.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Ubicación
  Widget _buildStep2(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Ubicación',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Completa la información para mostrar proveedores locales.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          // Form Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Country Selector
                Text(
                  'PAÍS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _countryController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Selecciona tu país',
                    hintStyle: GoogleFonts.plusJakartaSans(color: textVariant, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: primary),
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  onTap: () {
                    _showSearchablePicker(
                      title: 'Selecciona tu país',
                      options: excelCountriesAndStates.keys.toList(),
                      selectedValue: _selectedCountry,
                      onSelected: (val) {
                        setState(() {
                          _selectedCountry = val;
                          _countryController.text = val;
                          _selectedState = null; // Reset state
                          _stateController.clear();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // State Selector
                Text(
                  'PROVINCIA O ESTADO',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _stateController,
                  readOnly: true,
                  enabled: _selectedCountry != null,
                  decoration: InputDecoration(
                    hintText: _selectedCountry == null
                        ? 'Primero selecciona un país'
                        : 'Selecciona tu provincia o estado',
                    hintStyle: GoogleFonts.plusJakartaSans(color: textVariant, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: _selectedCountry == null ? textVariant : primary,
                    ),
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  onTap: _selectedCountry == null
                      ? null
                      : () {
                          _showSearchablePicker(
                            title: 'Selecciona tu provincia o estado',
                            options: excelCountriesAndStates[_selectedCountry] ?? [],
                            selectedValue: _selectedState,
                            onSelected: (val) {
                              setState(() {
                                _selectedState = val;
                                _stateController.text = val;
                              });
                            },
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Foto de perfil
  Widget _buildStep3(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Foto de Perfil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '¡Ya casi terminamos! Sube una foto para completar tu identidad.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          // Form Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Avatar Container
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3530) : const Color(0xFFCAEAD7),
                            width: 6,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundImage: _pickedImagePath != null
                              ? (kIsWeb
                                  ? NetworkImage(_pickedImagePath!) as ImageProvider
                                  : FileImage(File(_pickedImagePath!)) as ImageProvider)
                              : (_selectedAvatarUrl.startsWith('assets/')
                                  ? AssetImage(_selectedAvatarUrl) as ImageProvider
                                  : NetworkImage(_selectedAvatarUrl) as ImageProvider),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      // Camera Icon Badge
                      Container(
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBg, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Simulated picker button
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library, color: primary),
                  label: Text(
                    'SELECCIONAR DE GALERÍA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    side: BorderSide(color: primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
