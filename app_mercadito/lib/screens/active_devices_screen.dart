import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors from code.html
    const primaryGreen = Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final onSurfaceColor = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);
    final secondaryTextColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456);
    final outlineColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFbec9c1).withValues(alpha: 0.2);
    final errorColor = const Color(0xFFba1a1a);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF89d6b0) : primaryGreen),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sesiones Activas',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildCurrentDeviceCard(isDark, surfaceColor, onSurfaceColor, secondaryTextColor, outlineColor),
              const SizedBox(height: 32),
              _buildGlobalLogoutButton(errorColor),
              const SizedBox(height: 40),
              _buildSectionHeader('OTRAS SESIONES ACTIVAS', secondaryTextColor, trailing: '3 DISPOSITIVOS'),
              const SizedBox(height: 16),
              _buildOtherSessionsList(isDark, surfaceColor, onSurfaceColor, secondaryTextColor, outlineColor, errorColor),
              const SizedBox(height: 40),
              _buildSecurityTip(isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentDeviceCard(bool isDark, Color surfaceColor, Color onSurfaceColor, Color secondaryTextColor, Color outlineColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00462f).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'ESTE DISPOSITIVO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: const Color(0xFF00462f),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'iPhone 13',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      'Ciudad de México, MX',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00462f).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00462f).withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00462f),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'En línea ahora',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00462f),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF00462f).withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlineColor),
            ),
            child: const Icon(
              Icons.smartphone_rounded,
              size: 64,
              color: Color(0xFF00462f),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLogoutButton(Color errorColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.logout, size: 20, color: errorColor),
        label: Text(
          'CERRAR TODAS LAS SESIONES',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: errorColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: errorColor.withValues(alpha: 0.2), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 2.0,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
      ],
    );
  }

  Widget _buildOtherSessionsList(bool isDark, Color surfaceColor, Color onSurfaceColor, Color secondaryTextColor, Color outlineColor, Color errorColor) {
    final List<Map<String, dynamic>> sessions = [
      {
        'device': 'Chrome en Windows',
        'location': 'Santiago, GTO',
        'time': 'Activa hace 2 horas',
        'icon': Icons.desktop_windows,
      },
      {
        'device': 'Samsung Galaxy S21',
        'location': 'Guadalajara, JAL',
        'time': 'Activa hace 1 día',
        'icon': Icons.smartphone,
      },
      {
        'device': 'MacBook Pro 14"',
        'location': 'Ciudad de México, MX',
        'time': 'Activa hace 3 días',
        'icon': Icons.laptop_mac,
      },
    ];

    return Column(
      children: sessions.map((session) => _buildSessionCard(session, isDark, surfaceColor, onSurfaceColor, secondaryTextColor, outlineColor, errorColor)).toList(),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isDark, Color surfaceColor, Color onSurfaceColor, Color secondaryTextColor, Color outlineColor, Color errorColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: isDark ? 0.7 : 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlineColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(session['icon'], color: const Color(0xFF00462f), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['device'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: secondaryTextColor),
                          const SizedBox(width: 4),
                          Text(
                            session['location'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (session['time'] as String).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.logout, color: Colors.grey[400], size: 20),
                  style: IconButton.styleFrom(
                    hoverColor: errorColor.withValues(alpha: 0.1),
                    highlightColor: errorColor.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00462f),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00462f).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.verified_user, size: 100, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF89d6b0), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'CONSEJO DE SEGURIDAD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF89d6b0),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Si no reconoces alguno de estos dispositivos, te recomendamos cerrar la sesión y cambiar tu contraseña inmediatamente.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
