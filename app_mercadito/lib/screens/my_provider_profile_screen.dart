import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';
import '../services/reviews_service.dart';
import 'seller_policies_screen.dart';
import 'business_hours_screen.dart';
import 'business_verification_screen.dart';
import '../widgets/verified_badge.dart';

class MyProviderProfileScreen extends StatefulWidget {
  const MyProviderProfileScreen({super.key});

  @override
  State<MyProviderProfileScreen> createState() => _MyProviderProfileScreenState();
}

class _MyProviderProfileScreenState extends State<MyProviderProfileScreen> {
  // Mock products list based on the design files
  final List<Map<String, dynamic>> _myProducts = [
    {
      'name': 'Tomate Saladette Orgánico',
      'price': '12,500',
      'unit': 'Libra',
      'currency': 'MXN',
      'description': 'Cultivado en invernadero, libre de pesticidas. Calidad de exportación, calibre grande y color rojo intenso uniforme.',
      'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&q=80&w=600',
      'quality': 'PRIMERA',
      'rating': 4.9,
      'reviewsCount': 120,
      'negotiationsCount': 312,
      'isMostSold': true,
    },
    {
      'name': 'Aguacate Hass Premium',
      'price': '45,000',
      'unit': 'Saco',
      'currency': 'MXN',
      'description': 'Calibre 48, maduración controlada. Ideal para mercado gourmet y restaurantes de alta gama.',
      'image': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&q=80&w=600',
      'quality': 'SEGUNDA',
      'rating': 4.7,
      'reviewsCount': 85,
      'negotiationsCount': 178,
      'isMostSold': false,
    }
  ];

  ImageProvider _loadImage(String path, String defaultAsset) {
    if (path.isEmpty) {
      return AssetImage(defaultAsset);
    }
    if (path.startsWith('http') || path.startsWith('blob:')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (kIsWeb) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  void _openClientPreview(BuildContext context, String fullName, String specialty, String salesType, String avatarUrl) {
    final providerData = {
      'name': fullName,
      'code': '#PRO-88291',
      'memberSince': 'Miembro desde Enero 2022',
      'sector': (UserSession.state != null && UserSession.state!.isNotEmpty)
          ? 'Sector ${UserSession.state}'
          : 'Sector San Pedro',
      'distance': 'A 5 km prom.',
      'rating': '4.9',
      'level': 'Nivel 3',
      'tags': specialty,
      'specialty': specialty,
      'salesType': salesType,
      'reviews': '124 reseñas de clientes',
      'traded': '312 productos negociados',
      'open': true,
      'closeTime': '6:00 PM',
      'img': avatarUrl,
      'verified': true,
      'products': _myProducts,
      'policies': UserSession.currentSellerPolicies,
      'isOwner': true,
    };
    context.push('/provider', extra: providerData);
  }

  void _showEditProfileModal(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController(text: UserSession.fullName ?? 'Ricardo Mendoza');
    final descCtrl = TextEditingController(text: UserSession.businessDescription ?? '');
    final phoneCtrl = TextEditingController(text: UserSession.phone ?? '+52 8299421923');
    final emailCtrl = TextEditingController(text: UserSession.email ?? 'contacto@mercadito.com');
    String currentSpecialty = UserSession.specialty ?? 'Alimento Animal';
    String currentSalesType = UserSession.salesType ?? 'Al Detalle';

    final List<String> availableSpecialties = [
      'Alimento Animal',
      'Carnes y Derivados',
      'Frutas y Vegetales',
      'Lácteos y Huevos',
      'Granos y Cereales',
      'Flores y Plantas',
      'Insumos Agrícolas',
      'Otros',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF13281E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Editar Perfil de Negocio',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final lastChanged = UserSession.businessNameLastChangedDate;
                        final now = DateTime.now();
                        bool canChangeBusinessName = true;
                        int daysRemaining = 0;
                        DateTime? nextAllowedDate;

                        if (lastChanged != null) {
                          nextAllowedDate = DateTime(lastChanged.year, lastChanged.month + 3, lastChanged.day);
                          if (now.isBefore(nextAllowedDate)) {
                            canChangeBusinessName = false;
                            daysRemaining = nextAllowedDate.difference(now).inDays + 1;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: nameCtrl,
                              enabled: canChangeBusinessName,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Negocio / Finca',
                                prefixIcon: Icon(
                                  canChangeBusinessName ? Icons.storefront_rounded : Icons.lock_outline_rounded,
                                  color: canChangeBusinessName ? const Color(0xFF016042) : Colors.grey,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: !canChangeBusinessName,
                                fillColor: isDark ? Colors.white10 : const Color(0xFFF1F4F0),
                              ),
                            ),
                            if (!canChangeBusinessName) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'El nombre del negocio solo se puede cambiar cada 3 meses. Próximo cambio disponible en $daysRemaining días (${nextAllowedDate!.day.toString().padLeft(2, '0')}/${nextAllowedDate.month.toString().padLeft(2, '0')}/${nextAllowedDate.year}).',
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10.5,
                                          color: Color(0xFFB45309),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  'El nombre del negocio solo se podrá cambiar cada 3 meses.',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10.5,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF737373),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción / Sobre Mí',
                        hintText: 'Cuéntale a tus clientes sobre tu historia, cosechas y certificaciones...',
                        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF016042)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Teléfono / WhatsApp',
                        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF016042)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : const Color(0xFFF1F4F0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'El correo electrónico está vinculado a tu cuenta y no puede modificarse por seguridad.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10.5,
                          color: isDark ? Colors.grey[400] : const Color(0xFF737373),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Especialidad Comercial:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: availableSpecialties.map((spec) {
                        final isSel = currentSpecialty.toLowerCase() == spec.toLowerCase();
                        return ChoiceChip(
                          label: Text(spec),
                          selected: isSel,
                          showCheckmark: true,
                          checkmarkColor: Colors.white,
                          backgroundColor: const Color(0xFFF1F4F0),
                          selectedColor: const Color(0xFF016042),
                          side: BorderSide(
                            color: isSel ? const Color(0xFF016042) : const Color(0xFFCCDFD9),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF737373),
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                currentSpecialty = spec;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Modalidad de Venta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ['Al Detalle', 'Mayorista', 'Ambos'].map((type) {
                        final isSel = currentSalesType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          showCheckmark: true,
                          checkmarkColor: Colors.white,
                          backgroundColor: const Color(0xFFF1F4F0),
                          selectedColor: const Color(0xFF016042),
                          side: BorderSide(
                            color: isSel ? const Color(0xFF016042) : const Color(0xFFCCDFD9),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF737373),
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11.5,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                currentSalesType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final lastChanged = UserSession.businessNameLastChangedDate;
                          final now = DateTime.now();
                          bool canChange = true;
                          if (lastChanged != null) {
                            final nextAllowed = DateTime(lastChanged.year, lastChanged.month + 3, lastChanged.day);
                            if (now.isBefore(nextAllowed)) {
                              canChange = false;
                            }
                          }

                          final newName = nameCtrl.text.trim();
                          final bool nameChanged = newName.isNotEmpty && newName != (UserSession.fullName ?? '');

                          setState(() {
                            if (canChange && nameChanged) {
                              UserSession.fullName = newName;
                              UserSession.businessNameLastChangedDate = DateTime.now();
                            }
                            UserSession.businessDescription = descCtrl.text.trim();
                            UserSession.phone = phoneCtrl.text.trim();
                            // El correo electrónico no se modifica por seguridad
                            UserSession.specialty = currentSpecialty;
                            UserSession.salesType = currentSalesType;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil de negocio actualizado exitosamente'),
                              backgroundColor: Color(0xFF016042),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF016042),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSellerPoliciesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellerPoliciesScreen()),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openBusinessHoursScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BusinessHoursScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openBusinessVerificationScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BusinessVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildOpenStatusBadge(bool isDark) {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    final isSaturday = now.weekday == DateTime.saturday;

    bool isClosedToday = false;
    String scheduleToday = UserSession.weekdaySchedule;

    if (isSunday) {
      isClosedToday = UserSession.isSundayClosed;
      scheduleToday = UserSession.sundaySchedule;
    } else if (isSaturday) {
      isClosedToday = UserSession.isSaturdayClosed;
      scheduleToday = UserSession.saturdaySchedule;
    }

    if (isClosedToday || scheduleToday.toLowerCase() == 'cerrado') {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const Text(
            'CERRADO HOY',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFFEF4444),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            '• Abre próximo día hábil',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        const Text(
          'ABIERTO AHORA',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF10B981),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          '• Horario: $scheduleToday',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium Emerald Harvest colors
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final cardBgColor = isDark ? const Color(0xFF0f172a) : Colors.white;
    final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF285E44);
    final onSurfaceColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final onSurfaceVariantColor = isDark ? const Color(0xFFbec9c1) : const Color(0xFF3f4943);

    // Session Data with elegant defaults matching the Ricardo Mendoza design
    final String fullName = UserSession.fullName ?? 'Ricardo Mendoza';
    final String specialty = UserSession.specialty ?? 'Orgánico';
    final String salesType = UserSession.salesType ?? 'Al Detalle';
    final String description = UserSession.businessDescription ??
        'Con más de 15 años de experiencia en la agricultura tradicional y 5 años especializados en cultivos orgánicos certificados. Ubicados en los fértiles valles de Guanajuato, nuestro enfoque es la sostenibilidad y la calidad premium para mercados exigentes.';
    
    final avatarUrl = UserSession.profilePictureUrl ?? '';
    final bannerUrl = UserSession.bannerPictureUrl ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Top AppBar Area (Floating style matching premium mobile)
              _buildTopAppBar(context, primaryColor, onSurfaceColor, cardBgColor, fullName, specialty, salesType, avatarUrl, isDark),

              // 2. Banner & Profile Info Card (Overlapping layout)
              _buildBannerAndProfileHeader(
                context,
                fullName,
                specialty,
                salesType,
                avatarUrl,
                bannerUrl,
                primaryColor,
                cardBgColor,
                onSurfaceColor,
                onSurfaceVariantColor,
                isDark,
              ),

              // 3. Main Bento Grid & Content layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 700;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Business Bio & Shipping Capacity
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _buildProductorInfoCard(description, primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                                const SizedBox(height: 16),
                                _buildReputationCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildVerificationCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildContactoCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                                const SizedBox(height: 16),
                                _buildHorarioCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildUbicacionCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildSellerPoliciesCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildSettingsMenu(context, primaryColor, cardBgColor, onSurfaceColor, isDark),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column: Products in sale
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildProductsListSection(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildProductorInfoCard(description, primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                          const SizedBox(height: 16),
                          _buildReputationCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildVerificationCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildContactoCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                          const SizedBox(height: 16),
                          _buildHorarioCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildUbicacionCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildSellerPoliciesCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildProductsListSection(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildSettingsMenu(context, primaryColor, cardBgColor, onSurfaceColor, isDark),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(
    BuildContext context,
    Color primaryColor,
    Color onSurfaceColor,
    Color cardBgColor,
    String fullName,
    String specialty,
    String salesType,
    String avatarUrl,
    bool isDark,
  ) {
    return Container(
      color: cardBgColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Mi Perfil de Negocio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility_outlined, color: primaryColor),
                tooltip: 'Ver como Cliente',
                onPressed: () => _openClientPreview(context, fullName, specialty, salesType, avatarUrl),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: onSurfaceColor),
                onSelected: (value) {
                  if (value == 'preview') {
                    _openClientPreview(context, fullName, specialty, salesType, avatarUrl);
                  } else if (value == 'edit') {
                    _showEditProfileModal(context, isDark);
                  } else if (value == 'logout') {
                    UserSession.clear();
                    context.go('/login');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        const Text('Ver como Cliente'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        const Text('Editar Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAndProfileHeader(
    BuildContext context,
    String fullName,
    String specialty,
    String salesType,
    String avatarUrl,
    String bannerUrl,
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final bannerImage = bannerUrl.isEmpty
        ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0f8i6gAUC6lZoFgBhG_4D6gxiBJCmqyBhJlw-MBVqmC-A0cubQM4YpVOOZbUX6TOqjnFGXeesM7EukfXI9c6Ipc45Ks8uDdAXqajsDL9hPLE9xQfknUmDSpdKU1m9_sBQTw5RCdJpx2x1FCpsxMN1tHvHGe6oMIGWv6JiE7LdTTQmfWhKYWeBuH83jLO-c0_q7pzmsdN9QhF2AHaqVMjgSGwX9Rtozw3fR0t9MaxfdrKM7MT8fHppJ6050lahiGFtwhfXXUtPTds'
        : bannerUrl;
    final defaultAvatar = 'assets/images/Foto Sin perfil Proveedor.png';

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Image
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _loadImage(bannerImage, 'assets/images/Backgorund default.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
              // Overlapping Profile Avatar
              Positioned(
                bottom: -50,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBgColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image(
                          image: _loadImage(avatarUrl, defaultAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openBusinessVerificationScreen(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBgColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            UserSession.isProviderVerified
                                ? Icons.verified
                                : UserSession.isVerificationPending
                                    ? Icons.hourglass_top_rounded
                                    : UserSession.isVerificationRejected
                                        ? Icons.error_outline
                                        : Icons.verified,
                            color: UserSession.isProviderVerified
                                ? VerifiedBadge.verifiedBlue
                                : UserSession.isVerificationPending
                                    ? const Color(0xFFD97706)
                                    : UserSession.isVerificationRejected
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF94A3B8),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Business Details
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  fullName,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (UserSession.isProviderVerified) ...[
                const SizedBox(width: 6),
                const Tooltip(
                  message: 'Negocio Verificado Oficialmente (DGII & RNC)',
                  child: VerifiedBadge(size: 22, showWhiteCircle: true),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#PRO-88291',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: onSurfaceVariantColor)),
              const SizedBox(width: 8),
              Text(
                'Miembro desde Enero 2022',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: onSurfaceVariantColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Location Row (Sector)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  (UserSession.state != null && UserSession.state!.isNotEmpty)
                      ? 'Sector ${UserSession.state}, Guanajuato'
                      : 'Sector San Pedro, Guanajuato',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges Row: Specialty, Prestige Level, Sales Modality
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Specialty Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBD5C7), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, size: 12, color: Color(0xFF016042)),
                    const SizedBox(width: 4),
                    Text(
                      specialty.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Color(0xFF016042),
                      ),
                    ),
                  ],
                ),
              ),
              // Prestige Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFB45309)),
                    SizedBox(width: 4),
                    Text(
                      'Nivel 3',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              // Sales Type (Al Detalle, Por Mayor o Ambos)
              if (salesType == 'Al Detalle' || salesType == 'Ambos')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF059669), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sell_outlined, size: 11, color: Color(0xFFF1F9F7)),
                      SizedBox(width: 4),
                      Text(
                        'Al Detalle',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F9F7),
                        ),
                      ),
                    ],
                  ),
                ),
              if (salesType == 'Mayorista' || salesType == 'Por Mayor' || salesType == 'Ambos')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0369A1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0369A1), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 11, color: Color(0xFFEDF4F8)),
                      SizedBox(width: 4),
                      Text(
                        'Por Mayor',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEDF4F8),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Operating Status Chip
          _buildOpenStatusBadge(isDark),
          const SizedBox(height: 16),

          // Quick Action Bar: [Ver como Cliente]
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openClientPreview(context, fullName, specialty, salesType, avatarUrl),
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text(
                  'Ver como Cliente (Vista Previa)',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bento Tonal Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildBentoStatCard(
                  '4.9',
                  'CALIFICACIÓN',
                  Icons.star_rounded,
                  Colors.amber,
                  cardBgColor,
                  onSurfaceColor,
                  onSurfaceVariantColor,
                  hintText: 'Detalle',
                  onTap: () => _showRatingBreakdown(context, isDark),
                ),
                const SizedBox(width: 8),
                _buildBentoStatCard(
                  '124',
                  'RESEÑAS',
                  Icons.rate_review_outlined,
                  primaryColor,
                  cardBgColor,
                  onSurfaceColor,
                  onSurfaceVariantColor,
                  hintText: 'Ver todas',
                  onTap: () => context.push('/my-reviews'),
                ),
                const SizedBox(width: 8),
                _buildBentoStatCard(
                  '312',
                  'NEGOCIACIONES',
                  Icons.handshake_outlined,
                  primaryColor,
                  cardBgColor,
                  onSurfaceColor,
                  onSurfaceVariantColor,
                  hintText: 'Ver tratos',
                  onTap: () => context.push('/negotiations'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBentoStatCard(
    String val,
    String label,
    IconData icon,
    Color iconColor,
    Color cardBg,
    Color onSurface,
    Color onSurfaceVariant, {
    VoidCallback? onTap,
    String? hintText,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: onSurfaceVariant.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      val,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon, size: 14, color: iconColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hintText != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hintText,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF285E44),
                        ),
                      ),
                      const SizedBox(width: 1),
                      const Icon(Icons.chevron_right, size: 10, color: Color(0xFF285E44)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingBreakdown(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final onSurface = isDark ? Colors.white : const Color(0xFF181D1A);
    final onSurfaceVar = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const primaryColor = Color(0xFF285E44);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Calificaciones y Reputación',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: onSurfaceVar, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Overall Rating Summary Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '124 opiniones',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: onSurfaceVar,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildStarRow('5', 0.85, '105', onSurfaceVar),
                        const SizedBox(height: 4),
                        _buildStarRow('4', 0.10, '13', onSurfaceVar),
                        const SizedBox(height: 4),
                        _buildStarRow('3', 0.04, '5', onSurfaceVar),
                        const SizedBox(height: 4),
                        _buildStarRow('2', 0.01, '1', onSurfaceVar),
                        const SizedBox(height: 4),
                        _buildStarRow('1', 0.00, '0', onSurfaceVar),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/my-reviews');
                },
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text(
                  'Ver Todas las Reseñas de Clientes',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(String stars, double progress, String count, Color textCol) {
    return Row(
      children: [
        Text(
          stars,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, size: 10, color: Colors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF285E44)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 24,
          child: Text(
            count,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, color: textCol, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }


  Widget _buildProductorInfoCard(
    String bioText,
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sobre Mi',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bioText.trim().isNotEmpty
                ? bioText
                : 'Sin descripción registrada.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              height: 1.5,
              color: onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReputationCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final providerId = UserSession.selectedRole == 'proveedor' ? 'prov_current' : 'prov_granja_sol';
    final rep = ReviewsService.getProviderReputation(providerId);
    final criteria = ReviewsService.getProviderCriteria(providerId);

    final cardBg = cardBgColor;
    final borderColor = isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF016042).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: Color(0xFF016042), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPUTACIÓN DEL PROVEEDOR',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFF67C83B) : const Color(0xFF285E44),
                      ),
                    ),
                    Text(
                      'Evaluación directa y cumplimiento comercial',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262012) : const Color(0xFFFEF8E3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3AF43)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF2A439)),
                    const SizedBox(width: 4),
                    Text(
                      '${rep['overallRating']} · ${rep['totalReviews']} reseñas',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF2A439),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Confidence Pillars (User explicit requirement)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f231d) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildReputationMetricBadge(
                    icon: Icons.check_circle_outline_rounded,
                    value: '${rep['compliancePercent']}%',
                    label: 'Cumplimiento',
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildReputationMetricBadge(
                    icon: Icons.bolt_rounded,
                    value: '${rep['fastResponsePercent']}%',
                    label: 'Responde rápido',
                    color: const Color(0xFF0284C7),
                    isDark: isDark,
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildReputationMetricBadge(
                    icon: Icons.thumb_up_alt_outlined,
                    value: '${rep['recommendationPercent']}%',
                    label: 'Lo recomiendan',
                    color: const Color(0xFFD97706),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-evaluations criteria breakdown (7 exact criteria)
          Text(
            'Desglose de Calidad de Negociación',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildCriteriaScoreRow('Recomendación', criteria['Recomendación'] ?? 4.8, isDark),
          _buildCriteriaScoreRow('Calidad del servicio', criteria['Calidad del servicio'] ?? 4.9, isDark),
          _buildCriteriaScoreRow('Puntualidad', criteria['Puntualidad'] ?? 4.8, isDark),
          _buildCriteriaScoreRow('Comunicación', criteria['Comunicación'] ?? 4.9, isDark),
          _buildCriteriaScoreRow('Cumplimiento', criteria['Cumplimiento'] ?? 4.9, isDark),
          _buildCriteriaScoreRow('Confiabilidad', criteria['Confiabilidad'] ?? 4.8, isDark),
          _buildCriteriaScoreRow('Correspondencia con lo ofrecido', criteria['Correspondencia con lo ofrecido'] ?? 4.7, isDark),
        ],
      ),
    );
  }

  Widget _buildReputationMetricBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCriteriaScoreRow(String label, double score, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score / 5.0,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF016042)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactoCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
  ) {
    final String phone = UserSession.phone ?? '+52 464 123 4567';
    final String email = UserSession.email ?? 'contacto@mercadito.com';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contacto',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                phone,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: onSurfaceVariantColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                email,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: onSurfaceVariantColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final weekly = UserSession.currentWeeklySchedule;
    final mon = weekly.firstWhere((d) => d.dayName == 'Lunes', orElse: () => weekly[0]);
    final tue = weekly.firstWhere((d) => d.dayName == 'Martes', orElse: () => weekly[1]);
    final wed = weekly.firstWhere((d) => d.dayName == 'Miércoles', orElse: () => weekly[2]);
    final thu = weekly.firstWhere((d) => d.dayName == 'Jueves', orElse: () => weekly[3]);
    final fri = weekly.firstWhere((d) => d.dayName == 'Viernes', orElse: () => weekly[4]);
    final sat = weekly.firstWhere((d) => d.dayName == 'Sábado', orElse: () => weekly[5]);
    final sun = weekly.firstWhere((d) => d.dayName == 'Domingo', orElse: () => weekly[6]);

    final bool monToFriSame = [tue, wed, thu, fri].every((d) =>
        d.isActive == mon.isActive &&
        d.openTime.hour == mon.openTime.hour &&
        d.openTime.minute == mon.openTime.minute &&
        d.closeTime.hour == mon.closeTime.hour &&
        d.closeTime.minute == mon.closeTime.minute);

    final bool satSameAsMon = sat.isActive == mon.isActive &&
        sat.openTime.hour == mon.openTime.hour &&
        sat.openTime.minute == mon.openTime.minute &&
        sat.closeTime.hour == mon.closeTime.hour &&
        sat.closeTime.minute == mon.closeTime.minute;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Horario de Atención',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openBusinessHoursScreen(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 15, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Gestionar',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (monToFriSame && satSameAsMon && mon.isActive) ...[
            _buildScheduleRow('Lunes a Sábado', mon.formattedRange, primaryColor, onSurfaceColor, isDark, false),
            const SizedBox(height: 8),
            _buildScheduleRow('Domingo', sun.formattedRange, primaryColor, onSurfaceColor, isDark, !sun.isActive),
          ] else if (monToFriSame && mon.isActive) ...[
            _buildScheduleRow('Lunes a Viernes', mon.formattedRange, primaryColor, onSurfaceColor, isDark, false),
            const SizedBox(height: 8),
            _buildScheduleRow('Sábado', sat.formattedRange, primaryColor, onSurfaceColor, isDark, !sat.isActive),
            const SizedBox(height: 8),
            _buildScheduleRow('Domingo', sun.formattedRange, primaryColor, onSurfaceColor, isDark, !sun.isActive),
          ] else ...[
            for (int i = 0; i < weekly.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _buildScheduleRow(
                weekly[i].dayName,
                weekly[i].formattedRange,
                primaryColor,
                onSurfaceColor,
                isDark,
                !weekly[i].isActive,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleRow(
    String day,
    String schedule,
    Color primaryColor,
    Color onSurfaceColor,
    bool isDark,
    bool isClosed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            day,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: onSurfaceColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isClosed
                ? (isDark ? Colors.grey[800] : Colors.grey[200])
                : primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            schedule,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isClosed
                  ? (isDark ? Colors.grey[400] : Colors.grey[600])
                  : primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUbicacionCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final String location = (UserSession.streetAddress != null && UserSession.streetAddress!.isNotEmpty)
        ? '${UserSession.streetAddress}, ${UserSession.state ?? ""}, ${UserSession.country ?? ""}'
        : 'Valle de Santiago, Guanajuato, México';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ubicación',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            location,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: onSurfaceVariantColor,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBH7ADNB7QWvMbN33Gx_W3uAMM3kyaKNjbiBTi1fY3Sn5QlGIUG7Lfu93jpSklUVHqVn9uWyJrx-O7Kv6qwOzpFHvmeyi3gawpEQwgNo2qSJbINr_vDd-vX_eE51dy0VfjPJUd1hgMeFx3PKMmbJR4ZnDfevwnVv7g35h1NEG9lbvS3pvrQEruRanSbBeuKqi2unhwDtla0oV5ax8sxFHalcNqmYnSU_DgmqPp4VKU-sV1aO6TCrCo8PLcifbWHmKz8OaKVV_IyH7o',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.1)),
                  const Center(child: Icon(Icons.location_on, color: Colors.red, size: 32)),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.open_in_new, size: 16, color: isDark ? Colors.white : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsListSection(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Producto más negociado',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _myProducts.length > 2 ? 2 : _myProducts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = _myProducts[index];
            final bool isMostSold = p['isMostSold'] ?? false;
            
            final Widget cardContent = Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isMostSold)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Banner Image
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image(
                            image: _loadImage(p['image'] ?? '', 'assets/images/Foto Sin perfil Proveedor.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isMostSold)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.emoji_events, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'MÁS VENDIDO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Plus Jakarta Sans',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quality, Rating & Reviews Row
                        Row(
                          children: [
                            Builder(
                              builder: (context) {
                                final String qual = (p['quality'] ?? 'PRIMERA').toString().toUpperCase();
                                final Color qBg = qual == 'PRIMERA'
                                    ? const Color(0xFFDCE9E5)
                                    : qual == 'SEGUNDA'
                                        ? const Color(0xFFFFF4E5)
                                        : const Color(0xFFFDEDED);
                                final Color qText = qual == 'PRIMERA'
                                    ? const Color(0xFF016042)
                                    : qual == 'SEGUNDA'
                                        ? const Color(0xFFFF9A04)
                                        : const Color(0xFFF44336);

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: qBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$qual CALIDAD',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: qText,
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${p['rating'] ?? 5.0}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${p['reviewsCount'] ?? 0} reseñas)',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: onSurfaceVariantColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (isMostSold) ...[
                              const Icon(Icons.emoji_events_outlined, color: Color(0xFFFFB300), size: 18),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                p['name'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p['description'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: onSurfaceVariantColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Negotiations count chip
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00462f).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00462f).withValues(alpha: 0.18),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.handshake_outlined,
                                    size: 13,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${p['negotiationsCount'] ?? 0} negociaciones realizadas',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipo de Venta: Por ${p['unit']}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceVariantColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${p['price']} ${p['currency']}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            if (isMostSold) {
              return AnimatedGlowingBorder(
                borderWidth: 2.5,
                borderRadius: BorderRadius.circular(16),
                child: cardContent,
              );
            }
            return cardContent;
          },
        ),
      ],
    );
  }

  Widget _buildSellerPoliciesCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final policies = UserSession.currentSellerPolicies;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.policy_outlined, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Políticas del Vendedor',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openSellerPoliciesScreen(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 15, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Gestionar',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < policies.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _buildPolicyRow(policies[i], onSurfaceVariantColor),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String text, Color onSurfaceVariant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF00462f)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              height: 1.3,
              color: onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(
    BuildContext context,
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            'Editar Información de Negocio',
            Icons.edit_road_outlined,
            primaryColor,
            onSurfaceColor,
            isDark,
            true,
            onTap: () => _showEditProfileModal(context, isDark),
          ),
          _buildSettingsTile(
            'Privacidad del Perfil',
            Icons.lock_outline,
            primaryColor,
            onSurfaceColor,
            isDark,
            true,
            onTap: () => context.push('/privacy'),
          ),
          _buildSettingsTile(
            'Ajustes de Cuenta General',
            Icons.settings_outlined,
            primaryColor,
            onSurfaceColor,
            isDark,
            false,
            onTap: () => context.push('/account-config'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    Color primaryColor,
    Color onSurface,
    bool isDark,
    bool hasBorder, {
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: hasBorder
                ? Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ),
              if (trailingWidget != null) ...[
                trailingWidget,
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatusChip() {
    final status = UserSession.verificationStatus;
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (status == 'verified') {
      bg = const Color(0xFFF0F9FF);
      fg = VerifiedBadge.verifiedBlue;
      label = 'Verificado';
      icon = Icons.verified;
    } else if (status == 'pending') {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
      label = 'En Revisión';
      icon = Icons.hourglass_top_rounded;
    } else if (status == 'rejected') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      label = 'Rechazado';
      icon = Icons.error_outline;
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'No Verificado';
      icon = Icons.shield_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    bool isDark,
  ) {
    final bool isVerified = UserSession.isProviderVerified;
    final bool isPending = UserSession.isVerificationPending;
    final bool isRejected = UserSession.isVerificationRejected;
    final bool isLockedOut = UserSession.isVerificationLockedOut;

    Color badgeBg;
    Color borderColor;
    Widget leadingWidget;
    Widget buttonIcon;
    String title;
    String description;
    String actionLabel;
    Color actionColor;

    if (isVerified) {
      badgeBg = isDark ? const Color(0xFF0C2438) : const Color(0xFFF0F9FF);
      borderColor = const Color(0xFF38BDF8).withValues(alpha: 0.5);
      leadingWidget = const VerifiedBadge(size: 36, showWhiteCircle: true);
      buttonIcon = const VerifiedBadge(size: 16, showWhiteCircle: true);
      actionColor = VerifiedBadge.verifiedBlue;
      title = 'Insignia de Negocio Verificado Activa';
      description = 'Tu comercio cuenta con acreditación oficial de RNC (${UserSession.verifiedRncNumber ?? "Activo"}) y estatus DGII regularizado.';
      actionLabel = 'Ver Acreditación';
    } else if (isPending) {
      badgeBg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.5);
      leadingWidget = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 20),
      );
      buttonIcon = const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFD97706));
      actionColor = const Color(0xFFD97706);
      title = 'Verificación en Proceso de Revisión';
      description = 'Tus documentos están siendo validados. No podrás enviar otra solicitud hasta recibir una respuesta de revisión.';
      actionLabel = 'Consultar Estado';
    } else if (isLockedOut) {
      badgeBg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFEF4444).withValues(alpha: 0.5);
      leadingWidget = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 20),
      );
      buttonIcon = const Icon(Icons.lock_clock_rounded, size: 16, color: Color(0xFFDC2626));
      actionColor = const Color(0xFFDC2626);
      final days = UserSession.lockoutDaysRemaining;
      title = 'Verificación Bloqueada por 30 Días';
      description = 'Has alcanzado 3 intentos rechazados. Por seguridad, podrás solicitar una nueva verificación en $days días.';
      actionLabel = 'Consultar Bloqueo ($days días)';
    } else if (isRejected) {
      badgeBg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFEF4444).withValues(alpha: 0.5);
      leadingWidget = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
      );
      buttonIcon = const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFDC2626));
      actionColor = const Color(0xFFDC2626);
      final count = UserSession.verificationRejectionCount;
      title = 'Solicitud Requiere Corrección ($count/3)';
      description = UserSession.verificationRejectionReason ?? 'Hubo observaciones en los documentos fiscales presentados.';
      actionLabel = 'Reintentar Solicitud';
    } else {
      badgeBg = isDark ? const Color(0xFF0C2438) : const Color(0xFFF0F9FF);
      borderColor = VerifiedBadge.verifiedBlue.withValues(alpha: 0.35);
      leadingWidget = const VerifiedBadge(size: 36, showWhiteCircle: true);
      buttonIcon = const VerifiedBadge(size: 16, showWhiteCircle: true);
      actionColor = VerifiedBadge.verifiedBlue;
      title = 'Insignia Oficial de Negocio Verificado';
      description = 'Solicita la insignia de verificado para tu negocio, asi obtienes preferencias y máxima visibilidad ante compradores.';
      actionLabel = 'Solicitar Insignia';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: leadingWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        height: 1.35,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openBusinessVerificationScreen(context),
              icon: buttonIcon,
              label: Text(
                actionLabel,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: actionColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                backgroundColor: badgeBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGlowingBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;

  const AnimatedGlowingBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<AnimatedGlowingBorder> createState() => _AnimatedGlowingBorderState();
}

class _AnimatedGlowingBorderState extends State<AnimatedGlowingBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (!isTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double glowPulse = sin(_controller.value * 2 * pi);
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6F08).withValues(alpha: 0.18 + 0.08 * glowPulse),
                blurRadius: 10 + 4 * glowPulse,
                spreadRadius: 1 + 1 * glowPulse,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GlowingBorderPainter(
              animationValue: _controller.value,
              borderWidth: widget.borderWidth,
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.borderWidth),
              child: ClipRRect(
                borderRadius: widget.borderRadius - BorderRadius.all(Radius.circular(widget.borderWidth)),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderWidth;
  final BorderRadius borderRadius;

  _GlowingBorderPainter({
    required this.animationValue,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Sweeping gradient: White (0%) → Gold-Yellow #FFE136 (50%) → Deep Orange #FF6F08 (100%)
    final colors = [
      const Color(0xFFFFFFFF), // White  – 0%
      const Color(0xFFFFE136), // Gold-Yellow – 50%
      const Color(0xFFFF6F08), // Deep Orange – 100%
      const Color(0xFFFFFFFF), // White again for seamless loop
    ];
    final stops = [0.0, 0.5, 1.0, 1.0];

    paint.shader = SweepGradient(
      colors: colors,
      stops: stops,
      transform: GradientRotation(animationValue * 2 * pi),
      center: Alignment.center,
    ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
