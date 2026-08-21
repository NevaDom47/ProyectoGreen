import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import 'flash_offer_edit_dialog.dart';

class FlashOffersManagerScreen extends StatefulWidget {
  const FlashOffersManagerScreen({super.key});

  @override
  State<FlashOffersManagerScreen> createState() =>
      _FlashOffersManagerScreenState();
}

class _FlashOffersManagerScreenState extends State<FlashOffersManagerScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF004532);

  late TabController _tabController;
  final TextEditingController _productSearchController = TextEditingController();
  String _selectedFilter = 'Todas';
  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  // Track selected sales mode per available product ('retail' or 'wholesale')
  final Map<String, String> _availableProductSalesMode = {};

  // Track selected unit per available product ('KG', 'LB', 'CAJA', 'SACO')
  final Map<String, String> _availableProductSelectedUnit = {};

  // Catalog of available seller products that can be put on Flash Offer (Productos tab)
  final List<Map<String, dynamic>> _availableProducts = [
    {
      'name': 'Tomate Saladette',
      'category': 'Hortalizas',
      'priceRetailKg': 28.50,
      'priceWholesaleKg': 22.00,
      'price': '\$28.50',
      'unit': 'por KG',
      'availableUnits': ['KG', 'LB', 'CAJA'],
      'negotiations': '42 realizadas',
      'views': '1,280 vistas',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Don Pedro H.',
      'location': 'Central de Abastos, CDMX',
      'tags': ['Hortalizas', 'Fresco'],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYN02O86K6knfDqM1gBCrHpJwRGAAFnGsTyBuDx_bz_LwJVJVvlwFt52ynNfBtYQgv8dANxYu2V-EKIHFQTA29lFosAhweneCU27NDnXJgOCnd6DsdRiiCmRZUTFWZFj4N1Fe46X8YMsV49Az2KYcc3vuHSpM-NCUxis8P32yqk3cDgFMUtzp3734FiMXIr62ADYo5_MnwZbPxUA6n_UCdUv0CgnoMmOrf6wp2c1-CiDK2s3NG-_bD',
    },
    {
      'name': 'Aguacate Hass',
      'category': 'Frutas',
      'priceRetailKg': 48.00,
      'priceWholesaleKg': 38.00,
      'price': '\$48.00',
      'unit': 'por KG',
      'availableUnits': ['KG', 'LB', 'CAJA', 'SACO', 'BULTO', 'ARROBA', 'TON'],
      'negotiations': '68 realizadas',
      'views': '2,450 vistas',
      'rating': '4.8',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Huasca Farms',
      'location': 'Uruapan, Michoacán',
      'tags': ['Frutas', 'Exportación'],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzFUdJEljqU-maGlOCYJr48Yky6pxYw5HDib7_VK1wtVBuNeDeHn2DBN4J9qTg8bgBuawXdUccydbrF0VG6iRRTZSgp-Fm88SCOgPKFpl0f1J8yNP1NSmQNRqaBMdqmnC9XqNg1Y45IZVs4vXyEBUYezsrxGskz5cRj9f_Jh02xPW3MwMWEdAEtj0mNsplETXkT2NWn7W9mQn2hFO-lGYIZ2MiJjFFkH3INhJtV8aYabh1YYjLvte-',
    },
    {
      'name': 'Cebolla Morada Extra',
      'category': 'Hortalizas',
      'priceRetailKg': 22.00,
      'priceWholesaleKg': 16.50,
      'price': '\$22.00',
      'unit': 'por KG',
      'availableUnits': ['KG', 'LB', 'SACO'],
      'negotiations': '29 realizadas',
      'views': '890 vistas',
      'rating': '4.7',
      'badge': 'SEGUNDA CALIDAD',
      'supplier': 'AgroCebollas',
      'location': 'Irapuato, Guanajuato',
      'tags': ['Hortalizas'],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXcsVfAn4SXFQcHddnB5qMtM4renFwAuqO-lGdtcJtIIEmGl9tMDsFQiPgu60XnCWVebJO7iP0Ibk5dtJIqrh9Aanp9rZWGv7faUFsthP816CnkwG06d3lv6JAtK1L0AlnAz_e_RO8MTnW4_KInOanUlNL5k2AshcmFlzprpJxW1x81-1wvtFdgqmQ27XRJXCS6DLiTryvA9pgF60utXXNGEKTfgzyHZfbGio0iMIq4G_RBnQepN2i0vJ1-mywwHJNnmaXt1UMSH8',
    },
    {
      'name': 'Mango Ataulfo de Campo',
      'category': 'Frutas',
      'priceRetailKg': 34.00,
      'priceWholesaleKg': 26.00,
      'price': '\$34.00',
      'unit': 'por KG',
      'availableUnits': ['KG', 'LB', 'CAJA'],
      'negotiations': '54 realizadas',
      'views': '1,720 vistas',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Frutas del Soconusco',
      'location': 'Tapachula, Chiapas',
      'tags': ['Frutas', 'Dulce'],
      'img':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png',
    },
    {
      'name': 'Limón Persa Seleccionado',
      'category': 'Cítricos',
      'priceRetailKg': 18.00,
      'priceWholesaleKg': 13.50,
      'price': '\$18.00',
      'unit': 'por KG',
      'availableUnits': ['KG', 'LB', 'CAJA'],
      'negotiations': '38 realizadas',
      'views': '1,150 vistas',
      'rating': '4.6',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Cítricos del Golfo',
      'location': 'Martínez de la Torre, Veracruz',
      'tags': ['Cítricos', 'Jugo'],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro',
    },
  ];

  Map<String, String> _getCalculatedProductPrice(
    Map<String, dynamic> prod,
    String mode,
    String unit,
  ) {
    final double baseRetail =
        (prod['priceRetailKg'] as num?)?.toDouble() ?? 28.50;
    final double baseWholesale =
        (prod['priceWholesaleKg'] as num?)?.toDouble() ?? 22.00;

    double basePriceKg = (mode == 'wholesale') ? baseWholesale : baseRetail;
    double finalPrice = basePriceKg;
    String unitDisplay = 'kg';

    final u = unit.toUpperCase().replaceAll('POR ', '').trim();
    if (u == 'LB' || u == 'LIBRA') {
      finalPrice = basePriceKg / 2.20462;
      unitDisplay = 'lb';
    } else if (u == 'CAJA') {
      finalPrice = basePriceKg * 15.0;
      unitDisplay = 'caja';
    } else if (u == 'SACO') {
      finalPrice = basePriceKg * 20.0;
      unitDisplay = 'saco';
    } else if (u == 'BULTO') {
      finalPrice = basePriceKg * 25.0;
      unitDisplay = 'bulto';
    } else if (u == 'ARROBA' || u == '@') {
      finalPrice = basePriceKg * 11.339;
      unitDisplay = '@';
    } else if (u == 'TON' || u == 'TONELADA') {
      finalPrice = basePriceKg * 1000.0;
      unitDisplay = 'ton';
    } else if (u == 'MANOJO') {
      finalPrice = basePriceKg * 0.5;
      unitDisplay = 'manojo';
    } else {
      finalPrice = basePriceKg;
      unitDisplay = 'kg';
    }

    return {
      'price': '\$${finalPrice.toStringAsFixed(2)}',
      'unitLabel': unitDisplay,
    };
  }

  Widget _buildCardUnitSelector({
    required BuildContext context,
    required String productName,
    required String currentUnit,
    required List<String> availableUnitsList,
    required bool isDark,
    required Color activeColor,
  }) {
    if (availableUnitsList.isEmpty) return const SizedBox.shrink();

    // If 3 or fewer units, show direct chips
    if (availableUnitsList.length <= 3) {
      return Row(
        children:
            availableUnitsList.map((u) {
              final isUnitSelected =
                  currentUnit.toUpperCase() == u.toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _availableProductSelectedUnit[productName] = u;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUnitSelected
                              ? activeColor
                              : (isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            isUnitSelected
                                ? activeColor
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      u,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color:
                            isUnitSelected
                                ? Colors.white
                                : (isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      );
    }

    // For 4 or more units (e.g. 7 units), show top 2 + active unit + compact popup menu "+N ▾"
    final List<String> displayedUnits = [];
    displayedUnits.add(availableUnitsList[0]);

    if (availableUnitsList.length > 1) {
      displayedUnits.add(availableUnitsList[1]);
    }

    // If active unit is not in the first 2, display it so it's always visible
    final bool currentIsInDisplayed = displayedUnits.any(
      (u) => u.toUpperCase() == currentUnit.toUpperCase(),
    );

    if (!currentIsInDisplayed) {
      displayedUnits.removeLast();
      displayedUnits.add(currentUnit);
    }

    final hiddenCount = availableUnitsList.length - displayedUnits.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayedUnits.map((u) {
          final isUnitSelected = currentUnit.toUpperCase() == u.toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _availableProductSelectedUnit[productName] = u;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isUnitSelected
                          ? activeColor
                          : (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isUnitSelected
                            ? activeColor
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1)),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  u,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color:
                        isUnitSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          );
        }),
        // Compact dropdown popup menu button
        Theme(
          data: Theme.of(context).copyWith(
            cardColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          ),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 90, maxWidth: 140),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color:
                    isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
              ),
            ),
            tooltip: 'Ver todas las unidades ($hiddenCount más)',
            onSelected: (String selectedUnit) {
              setState(() {
                _availableProductSelectedUnit[productName] = selectedUnit;
              });
            },
            itemBuilder: (BuildContext ctx) {
              return availableUnitsList.map((unitOption) {
                final isSelected =
                    currentUnit.toUpperCase() == unitOption.toUpperCase();
                return PopupMenuItem<String>(
                  value: unitOption,
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unitOption,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                          color:
                              isSelected
                                  ? activeColor
                                  : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 14,
                          color: activeColor,
                        ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$hiddenCount',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 11,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueTextColor,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 11),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: valueTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF016042).withValues(alpha: 0.2)
            : const Color(0xFFEAF2E8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? const Color(0xFF016042).withValues(alpha: 0.4)
              : const Color(0xFFBBD5C7),
          width: 0.8,
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF016042),
        ),
      ),
    );
  }

  Widget _buildQualityChip(String quality, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _getQualityBadgeBgColor(quality, isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getQualityBadgeBorderColor(quality, isDark),
          width: 0.8,
        ),
      ),
      child: Text(
        quality.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _getQualityBadgeTextColor(quality, isDark),
        ),
      ),
    );
  }

  DateTimeRange? _historyDateRange;

  // List of concluded / past flash offers (Histórico tab - within last 15 days)
  List<Map<String, dynamic>> get _historyOffers {
    final now = DateTime.now();
    return [
      {
        'name': 'Papa Blanca Alpha',
        'category': 'Tubérculos',
        'discount': '-20%',
        'finalPrice': '\$18.00',
        'oldPrice': '\$22.50',
        'salesMode': 'retail',
        'unit': 'por KG',
        'badge': 'PRIMERA CALIDAD',
        'totalSoldKg': '50 KG',
        'totalRevenue': '\$900.00',
        'activeDuration': '12 Horas',
        'negotiations': '38 realizadas',
        'views': '1,850 vistas',
        'endedDate': 'Hoy, 15:30',
        'endedDateTime': now.subtract(const Duration(hours: 2)),
        'status': 'Finalizada',
        'img': 'assets/images/PapaGemini.png',
      },
      {
        'name': 'Melón Cantaloupe',
        'category': 'Frutas',
        'discount': '-35%',
        'finalPrice': '\$15.00',
        'oldPrice': '\$23.00',
        'salesMode': 'wholesale',
        'unit': 'por Cien (100 Unidades)',
        'badge': 'PRIMERA CALIDAD',
        'totalSoldKg': '480 KG',
        'totalRevenue': '\$7,200.00',
        'activeDuration': '24 Horas',
        'negotiations': '54 realizadas',
        'views': '2,420 vistas',
        'endedDate': 'Ayer, 21:00',
        'endedDateTime': now.subtract(const Duration(days: 1, hours: 3)),
        'status': 'Finalizada',
        'img':
            'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1549_Variedad%20de%20Aj%C3%ADes_simple_compose_01jwvncbmqfpvb7qv6rs3vh22x.png',
      },
      {
        'name': 'Chile Poblano de Primera',
        'category': 'Hortalizas',
        'discount': '-28%',
        'finalPrice': '\$26.00',
        'oldPrice': '\$36.00',
        'salesMode': 'wholesale',
        'unit': 'por Saco (50 LBS)',
        'badge': 'PRIMERA CALIDAD',
        'totalSoldKg': '320 KG',
        'totalRevenue': '\$8,320.00',
        'activeDuration': '18 Horas',
        'negotiations': '42 realizadas',
        'views': '1,930 vistas',
        'endedDate': 'Hace 3 días',
        'endedDateTime': now.subtract(const Duration(days: 3, hours: 5)),
        'status': 'Finalizada',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC8i3bYgCoFml8RIwzz2s32HSkKDvOTWEnX-bo6gt_9o4zdC9d3U0ZglOr_m6EMoKc6Oz2ryDTAoXTbMceJxM4huBHJNMRIBp_rkwcL972T0U0FipN8bSOaMvmlsOxI7peoA4M2Uq1zmuTbYTdHFlAe_A_VA3kLfbMf3thYxRRP7gU3H79Xu6gqxI8wfQqLd59xQyc9evPxWOYoH-ufQjjtXka1i6Bn6dDixAquahUTLyExdeosV0TZReH-nBZgtW2Wf1EEcK2VGiY',
      },
      {
        'name': 'Tomate Saladette',
        'category': 'Hortalizas',
        'discount': '-25%',
        'finalPrice': '\$21.30',
        'oldPrice': '\$28.50',
        'salesMode': 'retail',
        'unit': 'por Libra (LB)',
        'badge': 'SEGUNDA CALIDAD',
        'totalSoldKg': '650 LBS',
        'totalRevenue': '\$13,845.00',
        'activeDuration': '12 Horas',
        'negotiations': '67 realizadas',
        'views': '3,100 vistas',
        'endedDate': 'Hace 5 días',
        'endedDateTime': now.subtract(const Duration(days: 5, hours: 2)),
        'status': 'Finalizada',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBYN02O86K6knfDqM1gBCrHpJwRGAAFnGsTyBuDx_bz_LwJVJVvlwFt52ynNfBtYQgv8dANxYu2V-EKIHFQTA29lFosAhweneCU27NDnXJgOCnd6DsdRiiCmRZUTFWZFj4N1Fe46X8YMsV49Az2KYcc3vuHSpM-NCUxis8P32yqk3cDgFMUtzp3734FiMXIr62ADYo5_MnwZbPxUA6n_UCdUv0CgnoMmOrf6wp2c1-CiDK2s3NG-_bD',
      },
      {
        'name': 'Cebolla Morada Criolla',
        'category': 'Raíces',
        'discount': '-30%',
        'finalPrice': '\$15.40',
        'oldPrice': '\$22.00',
        'salesMode': 'wholesale',
        'unit': 'por Quintal (QQ)',
        'badge': 'TERCERA CALIDAD',
        'totalSoldKg': '210 QQ',
        'totalRevenue': '\$3,234.00',
        'activeDuration': '24 Horas',
        'negotiations': '29 realizadas',
        'views': '1,340 vistas',
        'endedDate': 'Hace 7 días',
        'endedDateTime': now.subtract(const Duration(days: 7, hours: 6)),
        'status': 'Finalizada',
        'img': 'assets/images/PapaGemini.png',
      },
      {
        'name': 'Zanahoria Suprema',
        'category': 'Raíces',
        'discount': '-20%',
        'finalPrice': '\$16.00',
        'oldPrice': '\$20.00',
        'salesMode': 'retail',
        'unit': 'por KG',
        'badge': 'PRIMERA CALIDAD',
        'totalSoldKg': '400 KG',
        'totalRevenue': '\$6,400.00',
        'activeDuration': '12 Horas',
        'negotiations': '45 realizadas',
        'views': '2,110 vistas',
        'endedDate': 'Hace 10 días',
        'endedDateTime': now.subtract(const Duration(days: 10, hours: 4)),
        'status': 'Finalizada',
        'img': 'assets/images/PapaGemini.png',
      },
      {
        'name': 'Aguacate Hass Premium',
        'category': 'Frutas',
        'discount': '-22%',
        'finalPrice': '\$37.40',
        'oldPrice': '\$48.00',
        'salesMode': 'wholesale',
        'unit': 'por Caja (20 KG)',
        'badge': 'PRIMERA CALIDAD',
        'totalSoldKg': '850 KG',
        'totalRevenue': '\$31,790.00',
        'activeDuration': '36 Horas',
        'negotiations': '82 realizadas',
        'views': '4,500 vistas',
        'endedDate': 'Hace 13 días',
        'endedDateTime': now.subtract(const Duration(days: 13, hours: 1)),
        'status': 'Finalizada',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDzFUdJEljqU-maGlOCYJr48Yky6pxYw5HDib7_VK1wtVBuNeDeHn2DBN4J9qTg8bgBuawXdUccydbrF0VG6iRRTZSgp-Fm88SCOgPKFpl0f1J8yNP1NSmQNRqaBMdqmnC9XqNg1Y45IZVs4vXyEBUYezsrxGskz5cRj9f_Jh02xPW3MwMWEdAEtj0mNsplETXkT2NWn7W9mQn2hFO-lGYIZ2MiJjFFkH3INhJtV8aYabh1YYjLvte-',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    startGlobalFlashTimer(); // Sincroniza reloj regresivo global
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getQualityBadgeBgColor(String badge, bool isDark) {
    final b = badge.toUpperCase();
    if (b.contains('PRIMERA') || b.contains('1')) {
      return isDark ? const Color(0xFF016042).withValues(alpha: 0.35) : const Color(0xFFDCE9E5);
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return isDark ? const Color(0xFFFF9A04).withValues(alpha: 0.25) : const Color(0xFFFFF4E5);
    } else {
      return isDark ? const Color(0xFFF44336).withValues(alpha: 0.25) : const Color(0xFFFDEDED);
    }
  }

  Color _getQualityBadgeTextColor(String badge, bool isDark) {
    final b = badge.toUpperCase();
    if (b.contains('PRIMERA') || b.contains('1')) {
      return isDark ? const Color(0xFF6EE7B7) : const Color(0xFF016042);
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return isDark ? const Color(0xFFFDBA74) : const Color(0xFFFF9A04);
    } else {
      return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFF44336);
    }
  }

  Color _getQualityBadgeBorderColor(String badge, bool isDark) {
    final b = badge.toUpperCase();
    if (b.contains('PRIMERA') || b.contains('1')) {
      return const Color(0xFF016042).withValues(alpha: 0.35);
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return const Color(0xFFFF9A04).withValues(alpha: 0.35);
    } else {
      return const Color(0xFFF44336).withValues(alpha: 0.35);
    }
  }

  IconData _getFilterChipIcon(String filterName) {
    final lower = filterName.toLowerCase().trim();
    if (lower == 'todas' || lower == 'todos') {
      return Icons.grid_view_rounded;
    } else if (lower == 'activas') {
      return Icons.bolt_rounded;
    } else if (lower == 'por vencer') {
      return Icons.hourglass_bottom_rounded;
    } else if (lower.contains('raíz') ||
        lower.contains('raiz') ||
        lower.contains('raíces') ||
        lower.contains('raices')) {
      return Icons.grass_rounded;
    } else if (lower.contains('fruta')) {
      return Icons.apple_rounded;
    } else if (lower.contains('hortaliza')) {
      return Icons.spa_rounded;
    } else if (lower.contains('tubérculo') || lower.contains('tuberculo')) {
      return Icons.agriculture_rounded;
    } else if (lower.contains('cítrico') || lower.contains('citrico')) {
      return Icons.wb_sunny_outlined;
    } else if (lower.contains('verdura') || lower.contains('legumbre')) {
      return Icons.eco_rounded;
    } else if (lower.contains('calidad')) {
      return Icons.workspace_premium_rounded;
    }
    return Icons.label_outline_rounded;
  }

  String _getOfferEndTimeFormatted(Map<String, dynamic> offer) {
    if (offer['endTimeFormatted'] != null &&
        offer['endTimeFormatted'].toString().isNotEmpty) {
      return offer['endTimeFormatted'];
    }
    final secs = offer['secondsRemaining'] as int? ?? 0;
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: secs));
    final isToday = endTime.day == now.day &&
        endTime.month == now.month &&
        endTime.year == now.year;
    final isTomorrow =
        endTime.difference(DateTime(now.year, now.month, now.day)).inDays == 1;
    final dayLabel = isToday
        ? 'hoy'
        : (isTomorrow ? 'mañana' : '${endTime.day}/${endTime.month}');
    final hour12 = endTime.hour % 12 == 0 ? 12 : endTime.hour % 12;
    final minuteStr = endTime.minute.toString().padLeft(2, '0');
    final period = endTime.hour >= 12 ? 'PM' : 'AM';
    return '$dayLabel, ${hour12.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  void _openEditDialog(
    Map<String, dynamic> product, {
    Map<String, dynamic>? existingOffer,
  }) async {
    final productName = product['name'] ?? product['title'] ?? '';
    if (existingOffer == null && isProductLockedForOffers(productName)) {
      final rem = getProductLockoutRemainingMinutes(productName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Producto bloqueado temporalmente por 3 cancelaciones previas. Podrás ofertar nuevamente en $rem minutos.',
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          FlashOfferEditDialog(product: product, existingOffer: existingOffer),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Oferta relámpago activada con éxito!'),
          backgroundColor: primaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCancelDialog(
    BuildContext context,
    int index,
    String productName,
    bool isDark,
    Color cardBg,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cancelar Oferta',
                style: TextStyle(
                    fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de cancelar la oferta para "$productName"? Esta acción la eliminará de las ofertas activas inmediatamente.\n\nNota: Si cancelas un mismo producto 3 veces antes de culminar su tiempo, se bloqueará por 1 hora.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Botón Principal: Cancelar Oferta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final current = List<Map<String, dynamic>>.from(
                      globalFlashOffers.value,
                    );
                    if (index >= 0 && index < current.length) {
                      final prevSecs =
                          current[index]['secondsRemaining'] as int? ?? 0;
                      current[index]['secondsRemaining'] = 0;
                      current[index]['status'] = 'Finalizada';
                      globalFlashOffers.value = current;

                      // Register cancellation if ended early
                      if (prevSecs > 0) {
                        registerOfferCancellation(productName);
                      }
                    }
                    setState(() {});
                    final isNowLocked = isProductLockedForOffers(productName);
                    final count = getProductCancellationCount(productName);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isNowLocked
                              ? '¡Oferta cancelada! "$productName" se ha bloqueado por 1 hora tras 3 cancelaciones anticipadas.'
                              : 'Oferta relámpago cancelada ($count/3 cancelaciones antes de bloqueo).',
                        ),
                        backgroundColor:
                            isNowLocked ? Colors.red.shade900 : Colors.redAccent,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancelar Oferta',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // 2. Opción Secundaria: Volver (DEBAJO del botón Cancelar Oferta)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Volver',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickHistoryDateRange(BuildContext context, bool isDark) async {
    final now = DateTime.now();
    final firstAllowed = now.subtract(const Duration(days: 15));
    final initialRange = _historyDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowed,
      lastDate: now,
      initialDateRange: initialRange,
      helpText: 'HISTORIAL (MÁXIMO 15 DÍAS)',
      cancelText: 'CANCELAR',
      confirmText: 'APLICAR',
      saveText: 'APLICAR',
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF016042),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF016042),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _historyDateRange = picked;
      });
    }
  }

  String _formatShortDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8F9FF);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFD9E3F4);

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/home-feed');
            }
          },
        ),
        title: const Text(
          'Gestor de Ofertas Relámpago',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: primaryColor),
            onPressed: () {
              // Quick action: switch to productos tab
              _tabController.animateTo(1);
            },
            tooltip: 'Crear Nueva Oferta',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: isDark
              ? Colors.grey.shade400
              : Colors.grey.shade600,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Ofertas', icon: Icon(Icons.bolt, size: 20)),
            Tab(
              text: 'Productos',
              icon: Icon(Icons.inventory_2_outlined, size: 20),
            ),
            Tab(text: 'Histórico', icon: Icon(Icons.history, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfertasTab(context, theme, isDark, cardBg, borderColor),
          _buildProductosTab(context, theme, isDark, cardBg, borderColor),
          _buildHistoricoTab(context, theme, isDark, cardBg, borderColor),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // PESTAÑA 1: OFERTAS (Active Offers Management)
  // ---------------------------------------------------------
  Widget _buildOfertasTab(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalFlashOffers,
      builder: (context, offers, _) {
        // Only offers with time remaining (secondsRemaining > 0) are considered active
        final activeOffersList = offers
            .where((o) => (o['secondsRemaining'] as int? ?? 0) > 0)
            .toList();
        final activeOffersCount = activeOffersList.length;

        // Extract all dynamic categories and tags from active offers & products
        final filterOptions = <String>['Todas', 'Activas', 'Por Vencer'];
        final dynamicTags = <String>{};
        for (final o in activeOffersList) {
          final cat = (o['category'] ?? '').toString().trim();
          if (cat.isNotEmpty && cat != 'General') {
            dynamicTags.add(cat);
          }
        }
        for (final p in _availableProducts) {
          final cat = (p['category'] ?? '').toString().trim();
          if (cat.isNotEmpty && cat != 'General') {
            dynamicTags.add(cat);
          }
        }
        for (final tag in dynamicTags) {
          if (!filterOptions.contains(tag)) {
            filterOptions.add(tag);
          }
        }

        // Comprehensive search filter across active offer cards
        final filteredOffers = activeOffersList.where((offer) {
          final secs = offer['secondsRemaining'] as int? ?? 0;

          // 1. Status or Category Tag Filter
          if (_selectedFilter == 'Por Vencer') {
            if (secs > 1800) {
              return false; // Solo ofertas por debajo de los 30 min (1800 segundos)
            }
          } else if (_selectedFilter == 'Activas' || _selectedFilter == 'Todas') {
            // All offers in activeOffersList have secondsRemaining > 0
          } else {
            // Filter by product tag / category (e.g. 'Raíces', 'Frutas', 'Hortalizas', 'Tubérculos', 'Cítricos')
            final offerCategory =
                (offer['category'] ?? '').toString().toLowerCase();
            final offerBadge = (offer['badge'] ?? '').toString().toLowerCase();
            final offerTags = (offer['tags'] is List)
                ? (offer['tags'] as List)
                    .map((e) => e.toString().toLowerCase())
                    .toList()
                : <String>[];
            final target = _selectedFilter.toLowerCase();

            final matchCategory =
                offerCategory == target || offerCategory.contains(target);
            final matchBadge = offerBadge.contains(target);
            final matchTag = offerTags.contains(target);

            if (!matchCategory && !matchBadge && !matchTag) {
              return false;
            }
          }

          // 2. Text Search query filter
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase().trim();

            final name = (offer['name'] ?? '').toString().toLowerCase();
            final price = (offer['price'] ?? '').toString().toLowerCase();
            final oldPrice = (offer['oldPrice'] ?? '').toString().toLowerCase();
            final discount = (offer['discount'] ?? '').toString().toLowerCase();
            final discountNum = (offer['discountNumber'] ?? '')
                .toString()
                .toLowerCase();
            final category = (offer['category'] ?? '').toString().toLowerCase();
            final badge = (offer['badge'] ?? '').toString().toLowerCase();
            final supplier = (offer['supplier'] ?? '').toString().toLowerCase();
            final tags = (offer['tags'] is List)
                ? (offer['tags'] as List).join(' ').toLowerCase()
                : '';

            final matchName = name.contains(q);
            final matchPrice = price.contains(q) || oldPrice.contains(q);
            final matchDiscount =
                discount.contains(q) ||
                discountNum.contains(q) ||
                '$discountNum%'.contains(q);
            final matchDetails =
                category.contains(q) ||
                badge.contains(q) ||
                supplier.contains(q) ||
                tags.contains(q);

            if (!matchName && !matchPrice && !matchDiscount && !matchDetails) {
              return false;
            }
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPI Bar (Emerald Harvest aesthetic - without Pause)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OFERTAS ACTIVAS',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$activeOffersCount Activas',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar & Filter Chips
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por nombre, precio, % descuento, etiquetas...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Filter Choice Chips with Icons & Product Tags (Strict Design Tokens)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    final iconData = _getFilterChipIcon(filter);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = filter);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF016042)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF016042)
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCCDFD9)),
                              width: 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF016042)
                                          .withValues(alpha: 0.22),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 15,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey.shade400
                                        : const Color(0xFF737373)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF737373)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Offers List / Bento Cards
              if (filteredOffers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bolt_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No hay ofertas que coincidan con la búsqueda',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Prueba buscando por producto, precio, etiquetas o porcentaje.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Oferta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOffers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (ctx, index) {
                    final offer = filteredOffers[index];
                    final originalIdx = offers.indexOf(offer);
                    return _buildActiveOfferCard(
                      context,
                      offer,
                      originalIdx,
                      isDark,
                      cardBg,
                      borderColor,
                      primaryColor,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveOfferCard(
    BuildContext context,
    Map<String, dynamic> offer,
    int originalIdx,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
  ) {
    final secsRemaining = offer['secondsRemaining'] as int? ?? 0;
    final isWholesale = (offer['salesMode'] ?? 'retail') == 'wholesale';
    final activeColor = isWholesale ? const Color(0xFF0369A1) : primaryColor;
    final endTimeStr = _getOfferEndTimeFormatted(offer);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Card Header Image & Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade200,
                  child: (offer['img'] ?? '').toString().startsWith('http')
                      ? Image.network(
                          offer['img'],
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.image, size: 40),
                        )
                      : Image.asset(
                          offer['img'] ?? 'assets/images/PapaGemini.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.image, size: 40),
                        ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Discount Tag (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer['discount'] ?? '-20%',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Status Badge / Timer (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (secsRemaining <= 1800)
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF004532),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimer(secsRemaining),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Title overlay (Bottom)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  offer['name'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Details Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price & Unit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio de Oferta',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              offer['price'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: activeColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              offer['oldPrice'] ?? '',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Modality & Unit Badges Row (Requirement 2)
                        Row(
                          children: [
                            // Modality Badge (Al por mayor / Al detalle)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isWholesale
                                    ? const Color(0xFF0369A1).withValues(alpha: 0.12)
                                    : const Color(0xFF047857).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isWholesale
                                      ? const Color(0xFF0369A1).withValues(alpha: 0.4)
                                      : const Color(0xFF047857).withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isWholesale
                                        ? Icons.storefront_outlined
                                        : Icons.shopping_bag_outlined,
                                    size: 11,
                                    color: isWholesale
                                        ? const Color(0xFF0369A1)
                                        : const Color(0xFF047857),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isWholesale ? 'Al Por Mayor' : 'Al Detalle',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isWholesale
                                          ? (isDark
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFF0369A1))
                                          : (isDark
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFF047857)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Unidad de Medida que contiene la oferta
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.scale_outlined,
                                    size: 11,
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (offer['unit'] ?? 'por KG').toString(),
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Badges Column (Categoría ARRIBA y Calidad ABAJO)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Categoría del Producto (Requirement 6)
                        _buildCategoryChip(
                          offer['category'] ?? 'General',
                          isDark,
                        ),
                        const SizedBox(height: 6),
                        // Etiqueta de Calidad (Requirement 5)
                        _buildQualityChip(
                          offer['badge'] ?? 'PRIMERA CALIDAD',
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  color: borderColor.withValues(alpha: 0.5),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Timing Row (Requirement 1: Inicio, Fin, Duración)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Inicio: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF047857),
                            ),
                          ),
                          TextSpan(
                            text: offer['startTime'] ?? 'hoy, 08:00 AM',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Fin: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          TextSpan(
                            text: endTimeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Duración: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : const Color(0xFF334155),
                            ),
                          ),
                          TextSpan(
                            text: offer['duration'] ?? '12 Horas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  color: borderColor.withValues(alpha: 0.5),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Real-Time Metrics (Requirement 3: Negociaciones & Visualizaciones)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricRow(
                        icon: Icons.handshake_outlined,
                        iconBgColor: const Color(0xFF047857).withValues(alpha: 0.12),
                        iconColor: const Color(0xFF047857),
                        label: 'NEGOCIACIONES EN TIEMPO REAL',
                        value: offer['negotiations'] ?? '24 realizadas',
                        valueTextColor: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricRow(
                        icon: Icons.visibility_outlined,
                        iconBgColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        iconColor: const Color(0xFF0284C7),
                        label: 'VISUALIZACIONES EN TIEMPO REAL',
                        value: offer['views'] ?? '1,420 vistas',
                        valueTextColor: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Single Action Button: Cancelar Oferta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(
                      context,
                      originalIdx,
                      offer['name'] ?? '',
                      isDark,
                      cardBg,
                    ),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Cancelar Oferta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        44,
                      ),
                      side: BorderSide(
                        color: Colors.redAccent.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  // ---------------------------------------------------------
  // PESTAÑA 2: PRODUCTOS (Available Catalog for Flash Offer)
  // ---------------------------------------------------------
  Widget _buildProductosTab(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    final categories = ['Todos', 'Hortalizas', 'Frutas', 'Cítricos'];
    final filteredAvailable = _availableProducts.where((prod) {
      // 1. Category filter
      if (_selectedCategory != 'Todos' &&
          prod['category'] != _selectedCategory) {
        return false;
      }

      // 2. Search query filter (name, price, quality, supplier, location, units, tags)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (prod['name'] ?? '').toString().toLowerCase();
        final category = (prod['category'] ?? '').toString().toLowerCase();
        final supplier = (prod['supplier'] ?? '').toString().toLowerCase();
        final location = (prod['location'] ?? '').toString().toLowerCase();
        final badge = (prod['badge'] ?? '').toString().toLowerCase();
        final negotiations =
            (prod['negotiations'] ?? '').toString().toLowerCase();
        final views = (prod['views'] ?? '').toString().toLowerCase();
        final priceRetail =
            (prod['priceRetailKg'] ?? '').toString().toLowerCase();
        final priceWholesale =
            (prod['priceWholesaleKg'] ?? '').toString().toLowerCase();
        final price = (prod['price'] ?? '').toString().toLowerCase();
        final tags = (prod['tags'] as List<dynamic>? ?? [])
            .map((t) => t.toString().toLowerCase())
            .join(' ');
        final units = (prod['availableUnits'] as List<dynamic>? ?? [])
            .map((u) => u.toString().toLowerCase())
            .join(' ');

        final matches = name.contains(query) ||
            category.contains(query) ||
            supplier.contains(query) ||
            location.contains(query) ||
            badge.contains(query) ||
            negotiations.contains(query) ||
            views.contains(query) ||
            priceRetail.contains(query) ||
            priceWholesale.contains(query) ||
            price.contains(query) ||
            tags.contains(query) ||
            units.contains(query);

        if (!matches) return false;
      }

      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner prompt
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF065F46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos Disponibles',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Selecciona cualquier producto de tu inventario para añadirlo a Oferta Relámpago con descuento especial.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar (Exact same style as Ofertas tab)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _productSearchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Buscar por nombre, precio, calidad, etiquetas...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            onPressed: () {
                              setState(() {
                                _productSearchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category Chips matching FilterChips style
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: primaryColor.withValues(alpha: 0.15),
                      highlightColor: primaryColor.withValues(alpha: 0.08),
                    ),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF016042),
                      backgroundColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF016042)
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCCDFD9)),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.grey.shade400
                                : const Color(0xFF737373)),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Available Products Grid or Empty State
          if (filteredAvailable.isEmpty)
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 52,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontraron productos',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No hay resultados para "$_searchQuery".'
                          : 'No hay productos en esta categoría.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _productSearchController.clear();
                          _searchQuery = '';
                          _selectedCategory = 'Todos';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Limpiar Filtros'),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredAvailable.length,
              itemBuilder: (ctx, index) {
                final prod = filteredAvailable[index];
                return _buildAvailableProductCard(context, prod, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableProductCard(
    BuildContext context,
    Map<String, dynamic> prod,
    bool isDark,
  ) {
    final String productName = prod['name'] ?? '';
    final String currentSalesMode =
        _availableProductSalesMode[productName] ?? 'retail';
    final String currentUnit =
        _availableProductSelectedUnit[productName] ??
        (prod['availableUnits'] as List<String>?)?.first ??
        'KG';

    final priceData = _getCalculatedProductPrice(
      prod,
      currentSalesMode,
      currentUnit,
    );
    final List<String> availableUnitsList = List<String>.from(
      prod['availableUnits'] ?? ['KG', 'LB', 'CAJA'],
    );

    final bool isWholesale = currentSalesMode == 'wholesale';
    final Color activeThemeColor =
        isWholesale ? const Color(0xFF0369A1) : const Color(0xFF047857);
    final bool isLocked = isProductLockedForOffers(productName);
    final int remainingLockout = getProductLockoutRemainingMinutes(productName);
    final bool hasActiveOffer = hasActiveOfferForProductUnit(
      productName: productName,
      salesMode: currentSalesMode,
      unit: currentUnit,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image (Top half)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: Container(
              height: 115,
              width: double.infinity,
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              child: (prod['img'] ?? '').toString().startsWith('http')
                  ? Image.network(
                      prod['img'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.shopping_bag, size: 36),
                    )
                  : Image.asset(
                      prod['img'] ?? 'assets/images/PapaGemini.png',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.shopping_bag, size: 36),
                    ),
            ),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),

                // Calculated Dynamic Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      priceData['price']!,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? (isWholesale
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF34D399))
                            : activeThemeColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '/ ${priceData['unitLabel']}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Sales Mode Switcher [ Detalle | Por Mayor ]
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _availableProductSalesMode[productName] = 'retail';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: currentSalesMode == 'retail'
                              ? const Color(0xFF047857)
                              : (isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: currentSalesMode == 'retail'
                                ? const Color(0xFF047857)
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 10,
                              color: currentSalesMode == 'retail'
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700]),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Detalle',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: currentSalesMode == 'retail'
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _availableProductSalesMode[productName] = 'wholesale';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: currentSalesMode == 'wholesale'
                              ? const Color(0xFF0369A1)
                              : (isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: currentSalesMode == 'wholesale'
                                ? const Color(0xFF0369A1)
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 10,
                              color: currentSalesMode == 'wholesale'
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700]),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Por Mayor',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: currentSalesMode == 'wholesale'
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Unit Selector (Responsive adaptive chips + popup for 4+ units)
                Row(
                  children: [
                    Text(
                      'Unidad: ',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    Expanded(
                      child: _buildCardUnitSelector(
                        context: context,
                        productName: productName,
                        currentUnit: currentUnit,
                        availableUnitsList: availableUnitsList,
                        isDark: isDark,
                        activeColor: activeThemeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Rating & Reviews
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      prod['rating'] ?? '4.8',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(128 reseñas)',
                      style: TextStyle(fontSize: 8.5, color: Colors.grey[500]),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 6),

                // Metric Rows Stacked (uno debajo del otro)
                // 1. CALIDAD
                _buildMetricRow(
                  icon: Icons.workspace_premium,
                  iconBgColor: _getQualityBadgeBgColor(
                    prod['badge'] ?? 'PRIMERA CALIDAD',
                    isDark,
                  ),
                  iconColor: _getQualityBadgeTextColor(
                    prod['badge'] ?? 'PRIMERA CALIDAD',
                    isDark,
                  ),
                  label: 'CALIDAD',
                  value: (prod['badge'] ?? 'PRIMERA CALIDAD')
                      .toString()
                      .toUpperCase(),
                  valueTextColor: _getQualityBadgeTextColor(
                    prod['badge'] ?? 'PRIMERA CALIDAD',
                    isDark,
                  ),
                ),
                const SizedBox(height: 5),

                // 2. NEGOCIACIONES
                _buildMetricRow(
                  icon: Icons.handshake_outlined,
                  iconBgColor: const Color(0xFF047857).withValues(alpha: 0.12),
                  iconColor: const Color(0xFF047857),
                  label: 'NEGOCIACIONES',
                  value: prod['negotiations'] ?? '35 realizadas',
                  valueTextColor: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF047857),
                ),
                const SizedBox(height: 5),

                // 3. VISUALIZACIONES
                _buildMetricRow(
                  icon: Icons.visibility_outlined,
                  iconBgColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  iconColor: const Color(0xFF0284C7),
                  label: 'VISUALIZACIONES',
                  value: prod['views'] ?? '1,280 vistas',
                  valueTextColor: isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0369A1),
                ),

                const SizedBox(height: 10),

                // Primary Action Button (Stateful: Bloqueado / Oferta Activa / Añadir Oferta)
                if (isLocked)
                  Container(
                    width: double.infinity,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_clock,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Bloqueado ($remainingLockout min)',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasActiveOffer)
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _tabController.animateTo(0);
                      },
                      icon: const Icon(
                        Icons.bolt,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      label: const Text(
                        'Oferta Activa',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFF59E0B),
                          width: 1.2,
                        ),
                        backgroundColor: Colors.amber.withValues(alpha: 0.08),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final customProduct = Map<String, dynamic>.from(prod);
                        customProduct['price'] = priceData['price'];
                        customProduct['unit'] = 'por ${priceData['unitLabel']}';
                        customProduct['salesMode'] = currentSalesMode;
                        customProduct['selectedUnit'] = currentUnit;
                        _openEditDialog(customProduct);
                      },
                      icon: const Icon(Icons.bolt, size: 14, color: Colors.white),
                      label: const Text(
                        'Añadir Oferta',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004532),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

  // ---------------------------------------------------------
  // PESTAÑA 3: HISTÓRICO (Ended / Past Flash Offers Log)
  // ---------------------------------------------------------
  Widget _buildHistoricoTab(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalFlashOffers,
      builder: (context, globalOffers, _) {
        // Collect all offers from global state whose time has expired (secondsRemaining <= 0)
        final expiredGlobalOffers = globalOffers
            .where((o) => (o['secondsRemaining'] as int? ?? 0) <= 0)
            .map((o) {
              final stock = o['stockLimit'] ?? 50;
              return {
                'name': o['name'] ?? 'Producto',
                'category': o['category'] ?? 'General',
                'discount': o['discount'] ?? '-20%',
                'finalPrice': o['price'] ?? '\$0.00',
                'oldPrice': o['oldPrice'] ?? '\$0.00',
                'salesMode': o['salesMode'] ?? 'retail',
                'unit': o['unit'] ?? 'por KG',
                'badge': o['badge'] ?? 'PRIMERA CALIDAD',
                'totalSoldKg': '$stock KG',
                'totalRevenue': o['price'] ?? '\$500.00',
                'activeDuration': o['duration'] ?? '12 Horas',
                'negotiations': o['negotiations'] ?? '38 realizadas',
                'views': o['views'] ?? '1,850 vistas',
                'endedDate': 'Hoy (Concluida)',
                'endedDateTime': DateTime.now(),
                'status': 'Finalizada',
                'img': o['img'] ?? 'assets/images/PapaGemini.png',
                'rawProduct': o,
              };
            })
            .toList();

        final combinedHistory = [...expiredGlobalOffers, ..._historyOffers];
        // Sort descending by completion date
        combinedHistory.sort((a, b) {
          final dtA = (a['endedDateTime'] as DateTime?) ?? DateTime.now();
          final dtB = (b['endedDateTime'] as DateTime?) ?? DateTime.now();
          return dtB.compareTo(dtA);
        });

        // Filter by date range (if selected) or default to the latest 5 offers (Point 4)
        final List<Map<String, dynamic>> displayHistory;
        final bool isDateFiltered = _historyDateRange != null;

        if (isDateFiltered) {
          final startDay = DateTime(
            _historyDateRange!.start.year,
            _historyDateRange!.start.month,
            _historyDateRange!.start.day,
          );
          final endDay = DateTime(
            _historyDateRange!.end.year,
            _historyDateRange!.end.month,
            _historyDateRange!.end.day,
            23,
            59,
            59,
          );

          displayHistory = combinedHistory.where((item) {
            final dt = item['endedDateTime'] as DateTime?;
            if (dt == null) return true;
            return dt.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
                dt.isBefore(endDay.add(const Duration(seconds: 1)));
          }).toList();
        } else {
          // Always show the latest 5 offers performed when entering this section (Point 4)
          displayHistory = combinedHistory.take(5).toList();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Ofertas Relámpago',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Revisa las ofertas concluidas, duración y métricas obtenidas.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Calendar Filter Bar (Point 3: Calendario con límite de 15 días)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDateFiltered
                        ? const Color(0xFF016042)
                        : borderColor,
                    width: isDateFiltered ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF016042).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF016042),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDateFiltered
                                ? 'Rango: ${_formatShortDate(_historyDateRange!.start)} - ${_formatShortDate(_historyDateRange!.end)}'
                                : 'Últimas 5 ofertas realizadas',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            isDateFiltered
                                ? '${displayHistory.length} oferta(s) encontrada(s)'
                                : 'Límite de búsqueda: últimos 15 días',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDateFiltered)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _historyDateRange = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                        label: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    const SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () => _pickHistoryDateRange(context, isDark),
                      icon: const Icon(Icons.tune, size: 14),
                      label: Text(isDateFiltered ? 'Cambiar' : 'Filtrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF016042),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // History list rendering
              if (displayHistory.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_toggle_off_outlined,
                        size: 44,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isDateFiltered
                            ? 'No se encontraron ofertas en este rango de fechas.'
                            : 'No hay ofertas finalizadas en el historial.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      if (isDateFiltered) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _historyDateRange = null;
                            });
                          },
                          child: const Text('Ver últimas 5 ofertas'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                Column(
                  children: displayHistory
                      .map(
                        (item) => _buildHistoryOfferCard(
                          context,
                          item,
                          isDark,
                          cardBg,
                          borderColor,
                          primaryColor,
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryOfferCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
  ) {
    final isWholesale = (item['salesMode'] ?? 'retail') == 'wholesale';
    final activeColor = isWholesale ? const Color(0xFF0369A1) : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Image + Title + Discount + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (item['img'] ?? '').toString().startsWith('http')
                        ? Image.network(
                            item['img'],
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.image, size: 28),
                          )
                        : Image.asset(
                            item['img'] ?? 'assets/images/PapaGemini.png',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.image, size: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['discount'] ?? '-20%',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            item['finalPrice'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: activeColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item['oldPrice'] ?? '',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2. Modality & Unit & Category & Quality Badges
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                // Modality Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isWholesale
                        ? const Color(0xFF0369A1).withValues(alpha: 0.12)
                        : const Color(0xFF047857).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isWholesale
                          ? const Color(0xFF0369A1).withValues(alpha: 0.4)
                          : const Color(0xFF047857).withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isWholesale
                            ? Icons.storefront_outlined
                            : Icons.shopping_bag_outlined,
                        size: 9.5,
                        color: isWholesale
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF047857),
                      ),
                      const SizedBox(width: 2.5),
                      Text(
                        isWholesale ? 'Al Por Mayor' : 'Al Detalle',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isWholesale
                              ? (isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0369A1))
                              : (isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Unit Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.scale_outlined,
                        size: 9.5,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 2.5),
                      Text(
                        (item['unit'] ?? 'por KG').toString(),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Badge (Requirement 6)
                _buildCategoryChip(item['category'] ?? 'General', isDark),

                // Quality Badge (Requirement 5)
                _buildQualityChip(item['badge'] ?? 'PRIMERA CALIDAD', isDark),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 8),

            // 3. Duración activa & Fecha de finalización (Point 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: Color(0xFF047857),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tiempo activa: ',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      item['activeDuration'] ?? '12 Horas',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['endedDate'] ?? 'Concluida',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Vendido & Recaudado
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📦 Vendido: ${item['totalSoldKg']}',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
                Text(
                  '💰 Recaudado: ${item['totalRevenue']}',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF047857),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 8),

            // 4. Métricas Obtenidas (Point 1: Negociaciones y Visualizaciones obtenidas)
            Row(
              children: [
                Expanded(
                  child: _buildMetricRow(
                    icon: Icons.handshake_outlined,
                    iconBgColor: const Color(0xFF047857).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF047857),
                    label: 'NEGOCIACIONES OBTENIDAS',
                    value: item['negotiations'] ?? '24 realizadas',
                    valueTextColor: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF047857),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricRow(
                    icon: Icons.visibility_outlined,
                    iconBgColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF0284C7),
                    label: 'VISUALIZACIONES OBTENIDAS',
                    value: item['views'] ?? '1,420 vistas',
                    valueTextColor: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0369A1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 5. Botón Reactivar Oferta
            SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openEditDialog(item['rawProduct'] ?? item);
                },
                icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF016042)),
                label: const Text(
                  'Reactivar Oferta con este Producto',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF016042),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: const Color(0xFF016042).withValues(alpha: 0.4),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

