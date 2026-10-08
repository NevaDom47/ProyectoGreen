import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/provider_map_item.dart';

class ProviderMapCard extends StatelessWidget {
  final ProviderMapItem provider;
  final VoidCallback onViewProfile;
  final VoidCallback onClose;

  const ProviderMapCard({
    super.key,
    required this.provider,
    required this.onViewProfile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const brandPrimary = Color(0xFF285E44);
    const brandAccent = Color(0xFFA5C2B7);
    final cardBg = isDark ? const Color(0xFF16251F) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F3) : const Color(0xFF1E293B);
    final subtextColor = isDark ? const Color(0xFFAAB8B1) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF243B32) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Image, Name, Verification, Close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Image / Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 62,
                      height: 62,
                      child: provider.img.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: provider.img,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: brandPrimary.withValues(alpha: 0.08),
                                child: Center(
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    size: 26,
                                    color: brandPrimary.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => _buildFallbackImage(brandPrimary),
                            )
                          : Image.asset(
                              provider.img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(brandPrimary),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                provider.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),
                            if (provider.verified) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: brandPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13, color: subtextColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                provider.sector,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text(
                              provider.rating,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: subtextColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.distance,
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Close (X) button
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: subtextColor),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    splashRadius: 18,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badges: Especialidad y Tipo de Venta
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip(
                    icon: Icons.storefront_outlined,
                    label: provider.specialty,
                    bgColor: isDark ? const Color(0xFF1E352B) : const Color(0xFFEBF4EE),
                    textColor: isDark ? const Color(0xFF86DFB0) : brandPrimary,
                    borderColor: isDark ? const Color(0xFF2C4A3C) : brandAccent.withValues(alpha: 0.5),
                  ),
                  _buildChip(
                    icon: Icons.local_offer_outlined,
                    label: 'Venta: ${provider.salesType}',
                    bgColor: isDark ? const Color(0xFF1A262E) : const Color(0xFFEEF6F8),
                    textColor: isDark ? const Color(0xFF86CFE8) : const Color(0xFF0284C7),
                    borderColor: isDark ? const Color(0xFF253B47) : const Color(0xFFBAE6FD),
                  ),
                  if (provider.open)
                    _buildChip(
                      icon: Icons.access_time_rounded,
                      label: 'Abierto hasta ${provider.formattedCloseTime}',
                      bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                      textColor: const Color(0xFF10B981),
                      borderColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Action Buttons Row: "Ver Perfil" & "Empezar" / Contactar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onViewProfile,
                      icon: const Icon(Icons.person_pin_circle_outlined, size: 18, color: Colors.white),
                      label: const Text(
                        'Ver Perfil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(Color primaryColor) {
    return Container(
      color: primaryColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(Icons.local_florist, size: 28, color: primaryColor),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
