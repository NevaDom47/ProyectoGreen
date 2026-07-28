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

class DaySchedule {
  final String dayName;
  bool isActive;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  DaySchedule({
    required this.dayName,
    this.isActive = true,
    this.openTime = const TimeOfDay(hour: 8, minute: 0),
    this.closeTime = const TimeOfDay(hour: 18, minute: 0),
  });

  String formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }
}

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 to 4 for Steps 1, 2, 3, 4, 5

  // Theme Constants
  static const Color _colorPrimary = Color(0xFF00462f);
  static const Color _colorBackground = Color(0xFFF7FAF5);
  static const Color _colorSurfaceCard = Colors.white;
  static const Color _colorOutlineVariant = Color(0xFFBEC9C1);
  static const Color _colorOnSurfaceVariant = Color(0xFF3F4943);

  // Form Fields & Keys
  final _formKeyStep1 = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  static const List<CountryPhoneCode> _phoneCodes = [
    CountryPhoneCode(isoCode: 'mx', code: '+52', name: 'México'),
    CountryPhoneCode(isoCode: 'co', code: '+57', name: 'Colombia'),
    CountryPhoneCode(isoCode: 'ar', code: '+54', name: 'Argentina'),
    CountryPhoneCode(isoCode: 'pe', code: '+51', name: 'Perú'),
    CountryPhoneCode(isoCode: 'cl', code: '+56', name: 'Chile'),
    CountryPhoneCode(isoCode: 'ec', code: '+593', name: 'Ecuador'),
    CountryPhoneCode(isoCode: 've', code: '+58', name: 'Venezuela'),
    CountryPhoneCode(isoCode: 'gt', code: '+502', name: 'Guatemala'),
  ];

  late CountryPhoneCode _selectedPhoneCode = _phoneCodes.first;

  // Step 2 variables
  String? _selectedSpecialty;
  String? _selectedSalesType;
  final _descriptionController = TextEditingController();

  final List<String> _specialties = [
    'Frutas y verduras',
    'Cereales y granos',
    'Alimento Animal',
    'Semillas',
    'Lacteos',
    'Huevos',
    'Carnes y Embutidos',
    'Otros',
  ];

  final List<String> _salesTypes = [
    'Mayorista',
    'Al Detalle',
    'Ambos',
  ];

  // Step 3 variables
  String? _selectedCountry;
  String? _selectedState;
  final _streetController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  bool _gpsConfirmed = false;
  bool _confirmingGps = false;

  // Step 4 variables
  final List<DaySchedule> _weeklySchedule = [
    DaySchedule(dayName: 'Lunes', isActive: true),
    DaySchedule(dayName: 'Martes', isActive: true),
    DaySchedule(dayName: 'Miércoles', isActive: true),
    DaySchedule(dayName: 'Jueves', isActive: true),
    DaySchedule(dayName: 'Viernes', isActive: true),
    DaySchedule(dayName: 'Sábado', isActive: false),
    DaySchedule(dayName: 'Domingo', isActive: false),
  ];

  // Step 5 variables
  File? _bannerFile;
  File? _profileFile;
  String? _pickedBannerPath;
  String? _pickedProfilePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isProfile) {
            _pickedProfilePath = image.path;
            if (!kIsWeb) {
              _profileFile = File(image.path);
            }
          } else {
            _pickedBannerPath = image.path;
            if (!kIsWeb) {
              _bannerFile = File(image.path);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showMediaSourceSheet(bool isProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E2220) : Colors.white;
        final primary = isDark ? const Color(0xFF8BD8B2) : _colorPrimary;

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isProfile ? 'Foto de Perfil' : 'Foto de Banner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona cómo deseas obtener la imagen de tu negocio.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withOpacity(0.75) : _colorOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, isProfile);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_camera, size: 32, color: primary),
                            const SizedBox(height: 8),
                            Text(
                              'Cámara',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, isProfile);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library, size: 32, color: primary),
                            const SizedBox(height: 8),
                            Text(
                              'Galería',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCountryCodePicker() {
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
                            final code = _phoneCodes[index];
                            final isSelected = code.isoCode == _selectedPhoneCode.isoCode;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPhoneCode = code;
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
                                        'assets/images/${code.isoCode}.png',
                                        width: 32,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.flag, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        code.name,
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
                                      code.code,
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
      if (_selectedSpecialty == null || _selectedSalesType == null || _descriptionController.text.trim().isEmpty) {
        _showErrorSnackBar('Por favor completa todos los campos del perfil.');
        return;
      }
    } else if (_currentStep == 2) {
      if (_selectedCountry == null || _selectedState == null || _streetController.text.trim().isEmpty) {
        _showErrorSnackBar('Por favor indica tu dirección de negocio completa.');
        return;
      }
      if (!_gpsConfirmed) {
        _showErrorSnackBar('Por favor confirma tu ubicación GPS presionando el botón.');
        return;
      }
    }

    if (_currentStep < 4) {
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
      context.go('/select-role');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _completeOnboarding() {
    // Save details to session
    UserSession.fullName = _businessNameController.text.trim();
    UserSession.phone = '${_selectedPhoneCode.code} ${_phoneController.text.trim()}';
    UserSession.country = _selectedCountry;
    UserSession.state = _selectedState;
    UserSession.streetAddress = _streetController.text.trim();
    
    // Default logo/profile if empty
    UserSession.profilePictureUrl = _pickedProfilePath ?? 'assets/images/Foto Sin perfil Proveedor.png';
    
    UserSession.bannerPictureUrl = _pickedBannerPath ?? 'assets/images/Backgorund default.png';
    UserSession.specialty = _selectedSpecialty;
    UserSession.salesType = _selectedSalesType;
    UserSession.businessDescription = _descriptionController.text.trim();
    UserSession.isProviderOnboarded = true;

    // Show premium confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              '¡Registro de Negocio exitoso!',
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

    // Proceed to home feed
    context.go('/home');
  }

  void _applySameScheduleToAll() {
    final monday = _weeklySchedule.first;
    setState(() {
      for (int i = 1; i < _weeklySchedule.length; i++) {
        _weeklySchedule[i].isActive = monday.isActive;
        _weeklySchedule[i].openTime = monday.openTime;
        _weeklySchedule[i].closeTime = monday.closeTime;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Horario de Lunes aplicado a todos los días.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _colorPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _simulateGpsCapture() async {
    setState(() {
      _confirmingGps = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _confirmingGps = false;
      _gpsConfirmed = true;
    });
  }

  Future<void> _selectTime(BuildContext context, DaySchedule day, bool isOpen) async {
    final initialTime = isOpen ? day.openTime : day.closeTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _colorPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _colorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          day.openTime = picked;
        } else {
          day.closeTime = picked;
        }
      });
    }
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
                                  borderSide: BorderSide(color: primary.withOpacity(0.5)),
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

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    super.dispose();
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
                        'Paso ${_currentStep + 1} de 5',
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
                              width: 120 * ((_currentStep + 1) / 5),
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
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep2(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep3(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep4(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                  _buildStep5(actualCardBg, actualPrimary, actualTextVariant, isDarkMode),
                ],
              ),
            ),

            // Bottom Action Bar
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
                        _currentStep == 4 ? 'FINALIZAR REGISTRO' : 'CONTINUAR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == 4 ? Icons.check_circle_outline : Icons.arrow_forward,
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

  // STEP 1: Información de negocio
  Widget _buildStep1(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Información de perfil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Registra los datos de contacto y de identidad del negocio.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.3),
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
                      Icon(Icons.storefront_outlined, color: primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '1. Datos de tu Negocio',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Business/Personal Name
                  Text(
                    'Nombre comercial o personal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Distribuidora Los Altos',
                    ),
                    onChanged: (v) => setState(() {}), // Refresh live card preview in Step 5
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa el nombre del negocio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),


                  // Phone number
                  Text(
                    'Teléfono de contacto',
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
                              onTap: _showCountryCodePicker,
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
                        return 'Ingresa un número de teléfono.';
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

  // STEP 2: ¿Quién eres?
  Widget _buildStep2(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            '¿Quién eres?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Queremos conocer más sobre tu especialidad y tu forma de trabajar.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined, color: primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '2. Perfil Comercial',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Specialty
                Text(
                  'ESPECIALIDAD',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  hint: Text(
                    'Selecciona tu especialidad principal',
                    style: GoogleFonts.plusJakartaSans(color: textVariant, fontSize: 14),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _specialties.map((val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSpecialty = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Sales Type
                Text(
                  'TIPO DE VENTA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSalesType,
                  hint: Text(
                    '¿Cómo vendes tus productos?',
                    style: GoogleFonts.plusJakartaSans(color: textVariant, fontSize: 14),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _salesTypes.map((val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSalesType = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Business description
                Text(
                  'DESCRIPCIÓN DE TU NEGOCIO',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos sobre tus productos, de dónde provienen y qué te hace único...',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Ubicación
  Widget _buildStep3(Color cardBg, Color primary, Color textVariant, bool isDark) {
    final stateOptions = _selectedCountry != null ? (excelCountriesAndStates[_selectedCountry] ?? <String>[]) : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Ubicación',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ingresa la dirección fiscal o comercial física de tu negocio.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.3),
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
                    suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: _selectedCountry == null ? textVariant : primary),
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
                const SizedBox(height: 20),

                // Street & Address
                Text(
                  'CALLE Y NÚMERO DEL LOCAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Av. de la República #450, Col. Centro',
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Confirm GPS
                ElevatedButton(
                  onPressed: _confirmingGps ? null : _simulateGpsCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gpsConfirmed 
                        ? (isDark ? const Color(0xFF14241C) : const Color(0xFFEAF2E8))
                        : (isDark ? const Color(0xFF27302B) : const Color(0xFFF1F4F0)),
                    foregroundColor: _gpsConfirmed ? primary : textVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _gpsConfirmed ? primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_confirmingGps) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _colorPrimary),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        Icon(
                          _gpsConfirmed ? Icons.check_circle : Icons.gps_fixed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _gpsConfirmed
                            ? 'UBICACIÓN GPS CONFIRMADA'
                            : _confirmingGps
                                ? 'CAPTURANDO GPS...'
                                : 'CAPTURAR UBICACIÓN GPS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pulsing Map Preview
                if (_gpsConfirmed) ...[
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBtacoUmVbIJoIJHXrhQ91xOlVDGDBUPHER_SJxIuP2CPBXkl22sG6zOZ-48ZrFcXlVjVjRgndPYmcqFNvx3GTW3AP9FVmaNgZBMlqVM6jGIlVKWq5Oc2tMfIv6R74qJMeQT_neylvGPu2OKUjOjJxgK393Cp19VOVBKNJHoaGHtRXVTWmIAzMK-Q1mha1T47V8MN2IMykWR15nfC5Ft07enLxuo_E-l60ejRoaMhnWkwrEFkXPCDyGfIu9Mq_FQ8aTV4S6jHgzv0c',
                              ),
                              fit: BoxFit.cover,
                              opacity: 0.8,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.white, size: 8),
                              const SizedBox(width: 6),
                              Text(
                                'Mapa de Cobertura Activo',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Horario
  Widget _buildStep4(Color cardBg, Color primary, Color textVariant, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Horario',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Configura los días y horarios en los que tu negocio estará disponible.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Quick Action Copy
          ElevatedButton.icon(
            onPressed: _applySameScheduleToAll,
            icon: Icon(Icons.content_copy, size: 18, color: primary),
            label: Text(
              'Aplicar mismo horario a todos los días',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF1E2621) : const Color(0xFFF1F4F0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _colorOutlineVariant.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Weekly schedule list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _weeklySchedule.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final day = _weeklySchedule[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: day.isActive ? cardBg : (isDark ? const Color(0xFF161C19) : const Color(0xFFECEFEA)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: day.isActive
                        ? (isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.4))
                        : Colors.transparent,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day.dayName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: day.isActive 
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[600] : Colors.grey[500]),
                            decoration: day.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        Switch(
                          value: day.isActive,
                          onChanged: (val) {
                            setState(() {
                              day.isActive = val;
                            });
                          },
                          activeColor: primary,
                          activeTrackColor: primary.withOpacity(0.3),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: day.isActive
                          ? Column(
                              children: [
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Apertura',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: textVariant,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          InkWell(
                                            onTap: () => _selectTime(context, day, true),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF171D1A) : const Color(0xFFF1F4F0),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    day.formatTime(context, day.openTime),
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Icon(Icons.schedule, size: 14, color: textVariant),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.arrow_right_alt, color: _colorOutlineVariant),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cierre',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: textVariant,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          InkWell(
                                            onTap: () => _selectTime(context, day, false),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF171D1A) : const Color(0xFFF1F4F0),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    day.formatTime(context, day.closeTime),
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Icon(Icons.schedule, size: 14, color: textVariant),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // STEP 5: Foto de perfil
  Widget _buildStep5(Color cardBg, Color primary, Color textVariant, bool isDark) {
    final liveBusinessName = _businessNameController.text.trim().isNotEmpty
        ? _businessNameController.text.trim()
        : 'Nombre de tu Negocio';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Foto de perfil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Personaliza el perfil de tu negocio agregando imágenes representativas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Banner upload zone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FOTO DE BANNER',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showMediaSourceSheet(false),
                borderRadius: BorderRadius.circular(16),
                child: _pickedBannerPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.network(
                                _pickedBannerPath!,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_pickedBannerPath!),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2621) : const Color(0xFFF1F4F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _colorOutlineVariant.withOpacity(0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, color: primary, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'Sube una imagen para el banner de tu negocio',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile picture upload zone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FOTO DE PERFIL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showMediaSourceSheet(true),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E2621) : const Color(0xFFF1F4F0),
                        border: Border.all(
                          color: _colorOutlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: _pickedProfilePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: kIsWeb
                                  ? Image.network(
                                      _pickedProfilePath!,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_pickedProfilePath!),
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : Icon(Icons.photo_camera, color: primary, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Puedes colocar el logo de tu negocio o una foto de perfil representativa.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textVariant, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Live card preview
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VISTA PREVIA DE TU PERFIL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D2220) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3530) : _colorOutlineVariant.withOpacity(0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner preview
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _pickedBannerPath != null
                            ? (kIsWeb
                                ? Image.network(
                                    _pickedBannerPath!,
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_pickedBannerPath!),
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ))
                            : Image.asset(
                                'assets/images/Backgorund default.png',
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        // Avatar overlay
                        Positioned(
                          top: 50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isDark ? const Color(0xFF1D2220) : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: _pickedProfilePath != null
                                    ? (kIsWeb
                                        ? Image.network(
                                            _pickedProfilePath!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_pickedProfilePath!),
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ))
                                    : Image.asset(
                                        'assets/images/Foto Sin perfil Proveedor.png',
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            liveBusinessName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_selectedSpecialty != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category_outlined, size: 12, color: textVariant),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedSpecialty!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
