import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountConfigScreen extends StatefulWidget {
  const AccountConfigScreen({super.key});

  @override
  State<AccountConfigScreen> createState() => _AccountConfigScreenState();
}

class _AccountConfigScreenState extends State<AccountConfigScreen> {
  // Local State for User Information
  String _fullName = 'Mateo Estrada';
  String _userName = '@mateo_cosecha';
  String _email = 'm.estrada@agro-mail.com';
  String _phone = '+52 55 1234 5678';
  bool _is2FAEnabled = true;

  void _showEditModal({
    required String label,
    required String initialValue,
    required Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // If editing a phone number, clean up non-digits from the initial value so it conforms to the digits-only rule
    final cleanValue = keyboardType == TextInputType.phone
        ? initialValue.replaceAll(RegExp(r'\D'), '')
        : initialValue;

    final TextEditingController controller = TextEditingController(text: cleanValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1c2c26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Editar $label',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFeef2ed) : const Color(0xFF00462f),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Asegúrate de ingresar información válida para mantener tu cuenta actualizada.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                inputFormatters: keyboardType == TextInputType.phone
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ]
                    : null,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF486456)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00462f), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave(controller.text);
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label actualizado correctamente'),
                        backgroundColor: const Color(0xFF00462f),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00462f),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'GUARDAR CAMBIOS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors from Emerald Harvest
    const primaryGreen = Color(0xFF00462f);
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF1c2c26) : Colors.white;
    final onSurfaceColor = isDark ? const Color(0xFFeef2ed) : const Color(0xFF181d1a);
    final secondaryTextColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF486456);
    final outlineColor = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF6f7a73).withOpacity(0.1);

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
          'Configuración de cuenta',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _buildProfileSection(theme, isDark, surfaceColor, onSurfaceColor, secondaryTextColor),
              const SizedBox(height: 32),
              _buildSectionHeader('INFORMACIÓN PERSONAL', secondaryTextColor),
              const SizedBox(height: 16),
              _buildPersonalInformationGrid(isDark, surfaceColor, onSurfaceColor, outlineColor),
              const SizedBox(height: 32),
              _buildSectionHeader('SEGURIDAD', secondaryTextColor),
              const SizedBox(height: 16),
              _buildSecuritySection(isDark, surfaceColor, onSurfaceColor, outlineColor, secondaryTextColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, bool isDark, Color surfaceColor, Color onSurfaceColor, Color secondaryTextColor) {
    const avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsIZyjU5mngGZVEHpehZnqLVn6gyd1kdzZNZHsiz7vXNJjiy5tPJ3Sh1HDtSAqwIrXET6t6AyIQB_JPZ5ab6IaEwqNl5W6g2qIP6JDYJJRRCqN04QcIYkR7uHXnesSDIClo2z9HlmZUNwsGGg2kFDzbCuDPGPs850rYWNJjfjiJ5h4-lZ9ZWHskxaDKZ61BPMJjHTU68qbM1zlyh8egGJuh3F9yKIms7grS7M-eyV46-rmWPkzmtTXJ__o7QrUUhU0mnCEcQ6RNzI';
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: surfaceColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            InkWell(
              onTap: () {
                // Placeholder for Avatar Edit
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función de editar avatar próximamente'))
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00462f),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _fullName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Productor Premium',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildPersonalInformationGrid(bool isDark, Color surfaceColor, Color onSurfaceColor, Color outlineColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Nombre completo', 
                _fullName, 
                isDark, 
                surfaceColor, 
                onSurfaceColor, 
                outlineColor,
                onTap: () => _showEditModal(
                  label: 'Nombre completo',
                  initialValue: _fullName,
                  onSave: (val) => setState(() => _fullName = val),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                'Nombre de usuario', 
                _userName, 
                isDark, 
                surfaceColor, 
                onSurfaceColor, 
                outlineColor,
                onTap: () => _showEditModal(
                  label: 'Nombre de usuario',
                  initialValue: _userName,
                  onSave: (val) => setState(() => _userName = val),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Correo electrónico', 
          _email, 
          isDark, 
          surfaceColor, 
          onSurfaceColor, 
          outlineColor, 
          isVerified: true,
          onTap: () => _showEditModal(
            label: 'Correo electrónico',
            initialValue: _email,
            keyboardType: TextInputType.emailAddress,
            onSave: (val) => setState(() => _email = val),
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Número de teléfono', 
          _phone, 
          isDark, 
          surfaceColor, 
          onSurfaceColor, 
          outlineColor,
          onTap: () => _showEditModal(
            label: 'Número de teléfono',
            initialValue: _phone,
            keyboardType: TextInputType.phone,
            onSave: (val) => setState(() => _phone = val),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, bool isDark, Color surfaceColor, Color onSurfaceColor, Color outlineColor, {bool isVerified = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00462f).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'VERIFICADO',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00462f),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(bool isDark, Color surfaceColor, Color onSurfaceColor, Color outlineColor, Color secondaryTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor),
      ),
      child: Column(
        children: [
          _buildSecurityTile(
            'Autenticación en dos pasos (2FA)',
            'Mayor seguridad para tus transacciones',
            Icons.verified_user,
            isDark,
            onSurfaceColor,
            secondaryTextColor,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            onTap: () => context.push('/2fa-config'),
          ),
          Divider(height: 1, color: outlineColor),
          _buildSecurityTile(
            'Cerrar sesión en otros dispositivos',
            '3 dispositivos activos actualmente',
            Icons.phonelink_erase,
            isDark,
            onSurfaceColor,
            secondaryTextColor,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            onTap: () => context.push('/active-devices'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(String title, String subtitle, IconData icon, bool isDark, Color titleColor, Color subtitleColor, {required Widget trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: titleColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
