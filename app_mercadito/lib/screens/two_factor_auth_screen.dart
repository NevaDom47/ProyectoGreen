import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  String _selectedMethod = 'sms'; // Default to SMS as per screenshot

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors (Emerald Harvest)
    const primaryGreen = Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final onSurfaceColor = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);
    final secondaryTextColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456);
    final outlineColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFbec9c1).withValues(alpha: 0.2);

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
          'Autenticación en 2 pasos',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Opcion 2FA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF89d6b0) : primaryGreen,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Elige un método para verificar tu identidad',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildMethodCard(
                        id: 'sms',
                        title: 'Mensaje de texto (SMS)',
                        subtitle: 'Recibe un código en tu teléfono registrado',
                        icon: Icons.smartphone,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        outlineColor: outlineColor,
                      ),
                      const SizedBox(height: 16),
                      _buildMethodCard(
                        id: 'email',
                        title: 'Correo electrónico',
                        subtitle: 'Recibe un código en tu email m***a@harvest.com',
                        icon: Icons.mail_outline,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        outlineColor: outlineColor,
                      ),
                      const SizedBox(height: 16),
                      _buildMethodCard(
                        id: 'app',
                        title: 'App de autenticación',
                        subtitle: 'Usa Google Authenticator o Authy',
                        icon: Icons.security,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        outlineColor: outlineColor,
                      ),
                      const SizedBox(height: 48),
                      _buildSecurityBanner(isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(isDark, primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color outlineColor,
  }) {
    final isSelected = _selectedMethod == id;
    final primaryGreen = const Color(0xFF00462f);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedMethod = id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryGreen : outlineColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf0f4ef),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF89d6b0).withValues(alpha: 0.7) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryGreen : Colors.grey.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: isSelected
                      ? Container(
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
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

  Widget _buildSecurityBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF00462f).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF00462f), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'TU SEGURIDAD ES NUESTRA PRIORIDAD NO COMPARTAS TUS DATOS.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF00462f),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isDark, Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_selectedMethod == 'sms') {
              context.push('/2fa-sms');
            } else if (_selectedMethod == 'email') {
              context.push('/2fa-email');
            } else if (_selectedMethod == 'app') {
              context.push('/2fa-authenticator');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            'CONTINUAR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
