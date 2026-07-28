import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';

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

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController(text: 'Tonelada');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Agregar Nuevo Producto',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF00462f),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    hintText: 'ej. Papas Blancas Alpha',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio (MXN)',
                          hintText: 'ej. 15000',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unidad de Medida',
                          hintText: 'ej. Tonelada, Saco',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del Producto',
                    hintText: 'Especificaciones del cultivo, calibre, calidad...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  setState(() {
                    _myProducts.add({
                      'name': nameController.text.trim(),
                      'price': priceController.text.trim(),
                      'unit': unitController.text.trim(),
                      'currency': 'MXN',
                      'description': descController.text.trim(),
                      'image': 'https://images.unsplash.com/photo-1601648764658-cf37e8c89b70?q=80&w=300&auto=format&fit=crop', // generic harvest image
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Producto agregado exitosamente!', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFF00462f),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00462f),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium Emerald Harvest colors
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final cardBgColor = isDark ? const Color(0xFF0f172a) : Colors.white;
    final primaryColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);
    final onSurfaceColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final onSurfaceVariantColor = isDark ? const Color(0xFFbec9c1) : const Color(0xFF3f4943);

    // Session Data with elegant defaults matching the Ricardo Mendoza design
    final String fullName = UserSession.fullName ?? 'Ricardo Mendoza';
    final String specialty = UserSession.specialty ?? 'Orgánico';
    final String salesType = UserSession.salesType ?? 'Ambos';
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
              _buildTopAppBar(context, primaryColor, onSurfaceColor, cardBgColor),

              // 2. Banner & Profile Info Card (Overlapping layout)
              _buildBannerAndProfileHeader(
                context,
                fullName,
                specialty,
                avatarUrl,
                bannerUrl,
                primaryColor,
                cardBgColor,
                onSurfaceColor,
                onSurfaceVariantColor,
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
                                _buildContactoCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                                const SizedBox(height: 16),
                                _buildHorarioCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildUbicacionCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                                const SizedBox(height: 16),
                                _buildSellerPoliciesCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
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
                          _buildContactoCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                          const SizedBox(height: 16),
                          _buildHorarioCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildUbicacionCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildProductsListSection(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor, isDark),
                          const SizedBox(height: 16),
                          _buildSellerPoliciesCard(primaryColor, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
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

  Widget _buildTopAppBar(BuildContext context, Color primaryColor, Color onSurfaceColor, Color cardBgColor) {
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
          Text(
            'Mi Perfil de Negocio',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: onSurfaceColor),
            onSelected: (value) {
              if (value == 'logout') {
                UserSession.clear();
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
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
    );
  }

  Widget _buildBannerAndProfileHeader(
    BuildContext context,
    String fullName,
    String specialty,
    String avatarUrl,
    String bannerUrl,
    Color primaryColor,
    Color cardBgColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
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
            color: Colors.black.withOpacity(0.04),
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
                  color: Colors.black.withOpacity(0.25),
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
                            color: Colors.black.withOpacity(0.08),
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
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00462f),
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBgColor, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.verified, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Business Details
          Text(
            fullName,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
            ),
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
          const SizedBox(height: 12),

          // Specialty Tag Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFcaead7).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFcaead7), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 12, color: Color(0xFF00462f)),
                const SizedBox(width: 4),
                Text(
                  specialty.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF00462f),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bento Tonal Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildBentoStatCard('4.9', 'CALIFICACIÓN', Icons.star, Colors.amber, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                const SizedBox(width: 8),
                _buildBentoStatCard('124', 'RESEÑAS', Icons.reviews, Colors.grey, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
                const SizedBox(width: 8),
                _buildBentoStatCard('312', 'NEGOCIACIONES', Icons.handshake, Colors.grey, cardBgColor, onSurfaceColor, onSurfaceVariantColor),
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
    Color onSurfaceVariant,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onSurfaceVariant.withOpacity(0.15)),
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
                    fontSize: 18,
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
            ),
          ],
        ),
      ),
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
            color: Colors.black.withOpacity(0.02),
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
            bioText,
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
            color: Colors.black.withOpacity(0.02),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(Icons.schedule_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Horario de Atención',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lunes a Sábado',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: onSurfaceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '8:00 AM - 6:00 PM',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Domingo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: onSurfaceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cerrado',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            color: Colors.black.withOpacity(0.02),
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
                  Container(color: Colors.black.withOpacity(0.1)),
                  const Center(child: Icon(Icons.location_on, color: Colors.red, size: 32)),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900]!.withOpacity(0.8) : Colors.white.withOpacity(0.8),
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

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String desc,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 16),
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
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
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
                      color: Colors.black.withOpacity(0.02),
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
                                  color: Colors.black.withOpacity(0.15),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: p['quality'] == 'PRIMERA'
                                    ? primaryColor.withOpacity(0.1)
                                    : p['quality'] == 'SEGUNDA'
                                        ? const Color(0xFFFF8A5B).withOpacity(0.15)
                                        : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${p['quality'] ?? "PRIMERA"} CALIDAD',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: p['quality'] == 'PRIMERA'
                                      ? primaryColor
                                      : p['quality'] == 'SEGUNDA'
                                          ? const Color(0xFFFF8A5B)
                                          : Colors.red[700],
                                  fontFamily: 'Plus Jakarta Sans',
                                  letterSpacing: 0.5,
                                ),
                              ),
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
                                color: const Color(0xFF00462f).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00462f).withOpacity(0.18),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Icon(Icons.policy_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Políticas del Vendedor',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPolicyRow('Muestra disponible para órdenes mayores a 5 toneladas.', onSurfaceVariantColor),
          const SizedBox(height: 8),
          _buildPolicyRow('Negociación de precios habilitada para compras recurrentes.', onSurfaceVariantColor),
          const SizedBox(height: 8),
          _buildPolicyRow('Garantía de calidad Mercadito (Reembolso parcial si la merma supera el 5%).', onSurfaceVariantColor),
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
            color: Colors.black.withOpacity(0.02),
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
            onTap: () {
              // Simula el ingreso a la edición
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edición de datos de negocio (Simulado)')),
              );
            },
          ),
          _buildSettingsTile(
            'Gestionar Horarios de Atención',
            Icons.schedule_outlined,
            primaryColor,
            onSurfaceColor,
            isDark,
            true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestión de horarios de atención (Simulado)')),
              );
            },
          ),
          _buildSettingsTile(
            'Configurar Políticas de Venta',
            Icons.rule_folder_outlined,
            primaryColor,
            onSurfaceColor,
            isDark,
            true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración de políticas (Simulado)')),
              );
            },
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
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
                color: const Color(0xFFFF6F08).withOpacity(0.18 + 0.08 * glowPulse),
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
