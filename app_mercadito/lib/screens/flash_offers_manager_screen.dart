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
  String _selectedFilter = 'Todas';
  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  // Catalog of available seller products that can be put on Flash Offer (Productos tab)
  final List<Map<String, dynamic>> _availableProducts = [
    {
      'name': 'Tomate Saladette',
      'category': 'Hortalizas',
      'price': '\$28.50',
      'unit': 'por KG',
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
      'price': '\$48.00',
      'unit': 'por KG',
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
      'price': '\$22.00',
      'unit': 'por KG',
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
      'price': '\$34.00',
      'unit': 'por KG',
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
      'price': '\$18.00',
      'unit': 'por KG',
      'rating': '4.6',
      'badge': 'PRIMERA CALIDAD',
      'supplier': 'Cítricos del Golfo',
      'location': 'Martínez de la Torre, Veracruz',
      'tags': ['Cítricos', 'Jugo'],
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro',
    },
  ];

  // List of concluded / past flash offers (Histórico tab)
  final List<Map<String, dynamic>> _historyOffers = [
    {
      'name': 'Melón Cantaloupe',
      'category': 'Frutas',
      'discount': '-35%',
      'finalPrice': '\$15.00',
      'oldPrice': '\$23.00',
      'totalSoldKg': '480 KG',
      'totalRevenue': '\$7,200.00',
      'endedDate': 'Ayer, 21:00',
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
      'totalSoldKg': '320 KG',
      'totalRevenue': '\$8,320.00',
      'endedDate': 'hace 3 días',
      'status': 'Finalizada',
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC8i3bYgCoFml8RIwzz2s32HSkKDvOTWEnX-bo6gt_9o4zdC9d3U0ZglOr_m6EMoKc6Oz2ryDTAoXTbMceJxM4huBHJNMRIBp_rkwcL972T0U0FipN8bSOaMvmlsOxI7peoA4M2Uq1zmuTbYTdHFlAe_A_VA3kLfbMf3thYxRRP7gU3H79Xu6gqxI8wfQqLd59xQyc9evPxWOYoH-ufQjjtXka1i6Bn6dDixAquahUTLyExdeosV0TZReH-nBZgtW2Wf1EEcK2VGiY',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    startGlobalFlashTimer(); // Sincroniza reloj regresivo global
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      return const Color(
        0xFF10B981,
      ).withValues(alpha: 0.15); // Verde semitransparente
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return const Color(
        0xFFF97316,
      ).withValues(alpha: 0.15); // Mamey semitransparente
    } else {
      return const Color(
        0xFFEF4444,
      ).withValues(alpha: 0.15); // Rojo semitransparente
    }
  }

  Color _getQualityBadgeTextColor(String badge, bool isDark) {
    final b = badge.toUpperCase();
    if (b.contains('PRIMERA') || b.contains('1')) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
    } else {
      return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
    }
  }

  Color _getQualityBadgeBorderColor(String badge, bool isDark) {
    final b = badge.toUpperCase();
    if (b.contains('PRIMERA') || b.contains('1')) {
      return const Color(0xFF10B981).withValues(alpha: 0.3);
    } else if (b.contains('SEGUNDA') || b.contains('2')) {
      return const Color(0xFFF97316).withValues(alpha: 0.3);
    } else {
      return const Color(0xFFEF4444).withValues(alpha: 0.3);
    }
  }

  void _openEditDialog(
    Map<String, dynamic> product, {
    Map<String, dynamic>? existingOffer,
  }) async {
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

  void _cancelOffer(int index, String productName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cancelar Oferta Relámpago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de cancelar la oferta para "$productName"? Esta acción la eliminará y dejará de estar disponible para los compradores inmediatamente.',
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
                      current[index]['secondsRemaining'] = 0;
                      current[index]['status'] = 'Finalizada';
                      globalFlashOffers.value = current;
                    }
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Oferta relámpago cancelada y movida al histórico.',
                        ),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
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

        // Comprehensive search filter across active offer cards
        final filteredOffers = activeOffersList.where((offer) {
          final secs = offer['secondsRemaining'] as int? ?? 0;
          if (_selectedFilter == 'Por Vencer') {
            if (secs > 1800) {
              return false; // Solo ofertas por debajo de los 30 min (1800 segundos)
            }
          }

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

              // Filter Chips without black border!
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todas', 'Activas', 'Por Vencer'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: primaryColor.withValues(alpha: 0.15),
                          highlightColor: primaryColor.withValues(alpha: 0.08),
                        ),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: primaryColor.withValues(alpha: 0.15),
                          checkmarkColor: primaryColor,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide.none,
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? primaryColor
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                            }
                          },
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
                    final secsRemaining =
                        offer['secondsRemaining'] as int? ?? 0;

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
                          // Card Header Image & Badges
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
                                  color: Colors.grey.shade200,
                                  child:
                                      (offer['img'] ?? '')
                                          .toString()
                                          .startsWith('http')
                                      ? Image.network(
                                          offer['img'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              const Icon(Icons.image, size: 40),
                                        )
                                      : Image.asset(
                                          offer['img'] ??
                                              'assets/images/PapaGemini.png',
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
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),

                              // Discount Tag
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
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

                              // Status Badge / Timer (Fondo Mamey/Rojo sutil si le quedan <= 30 min)
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
                                        : primaryColor,
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

                              // Product Title overlay
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

                          // Details Body
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              offer['price'] ?? '',
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              offer['oldPrice'] ?? '',
                                              style: TextStyle(
                                                fontFamily: 'JetBrains Mono',
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // Etiqueta de Calidad (Primera, Segunda o Tercera Calidad)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getQualityBadgeBgColor(
                                              offer['badge'] ??
                                                  'PRIMERA CALIDAD',
                                              isDark,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _getQualityBadgeBorderColor(
                                                    offer['badge'] ??
                                                        'PRIMERA CALIDAD',
                                                    isDark,
                                                  ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            (offer['badge'] ??
                                                    'PRIMERA CALIDAD')
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: _getQualityBadgeTextColor(
                                                offer['badge'] ??
                                                    'PRIMERA CALIDAD',
                                                isDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Categoría del Producto
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            offer['category'] ?? 'General',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.grey.shade300
                                                  : const Color(0xFF047857),
                                            ),
                                          ),
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

                                // Inicio y Duración de la Oferta (Solicitud del Usuario)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Inicio: ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xFF047857),
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                offer['startTime'] ??
                                                'hoy, 08:00 AM',
                                            style: const TextStyle(
                                              fontSize: 13,
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
                                          TextSpan(
                                            text: 'Duracion: ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : const Color(0xFF334155),
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                offer['duration'] ?? '12 Horas',
                                            style: TextStyle(
                                              fontSize: 13,
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

                                const SizedBox(height: 14),

                                // Single Action Button: Cancelar Oferta (Requests: No editar, no pausar, solo cancelar)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _cancelOffer(
                                      originalIdx,
                                      offer['name'] ?? '',
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
                  },
                ),
            ],
          ),
        );
      },
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
      if (_selectedCategory != 'Todos' &&
          prod['category'] != _selectedCategory) {
        return false;
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

          const SizedBox(height: 20),

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
                      selectedColor: primaryColor.withValues(alpha: 0.15),
                      checkmarkColor: primaryColor,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      ),
                      labelStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white : Colors.black87),
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

          const SizedBox(height: 20),

          // Available Products Grid / Cards (Rich description matching _buildFlashOffers design)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.44,
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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(19),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
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

          // Content Details (Rich description style matching _buildFlashOffers)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                Text(
                  prod['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),

                // Price Row
                Text(
                  '${prod['price']} / kg',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 6),

                // Sales Mode Badges [ Detalle ] [ Por Mayor ]
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF047857).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 10,
                            color: Color(0xFF047857),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Detalle',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.store_outlined,
                            size: 10,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Por Mayor',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Rating & Reviews
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 12,
                    ),
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
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Divider(
                  color: Colors.grey.withValues(alpha: 0.2),
                  height: 1,
                ),
                const SizedBox(height: 6),

                // CALIDAD Row
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getQualityBadgeBgColor(
                          prod['badge'] ?? 'PRIMERA CALIDAD',
                          isDark,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: _getQualityBadgeTextColor(
                          prod['badge'] ?? 'PRIMERA CALIDAD',
                          isDark,
                        ),
                        size: 11,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CALIDAD',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            (prod['badge'] ?? 'PRIMERA CALIDAD')
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: _getQualityBadgeTextColor(
                                prod['badge'] ?? 'PRIMERA CALIDAD',
                                isDark,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Primary Action Button "⚡ Añadir Oferta"
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _openEditDialog(prod),
                    icon: const Icon(
                      Icons.bolt,
                      size: 15,
                      color: Colors.white,
                    ),
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
                        borderRadius: BorderRadius.circular(12),
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
                'totalSoldKg': '$stock KG',
                'totalRevenue': o['price'] ?? '\$500.00',
                'endedDate': 'Finalizada (Concluida)',
                'status': 'Finalizada',
                'img': o['img'] ?? 'assets/images/PapaGemini.png',
                'rawProduct': o,
              };
            })
            .toList();

        final combinedHistory = [...expiredGlobalOffers, ..._historyOffers];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 4),
              Text(
                'Revisa las ofertas concluidas y sus métricas de rendimiento.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              if (combinedHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    'No hay ofertas finalizadas en el historial',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: combinedHistory.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final item = combinedHistory[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  (item['img'] ?? '').toString().startsWith(
                                    'http',
                                  )
                                  ? Image.network(
                                      item['img'],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(item['img'], fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['discount'] ?? '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vendido: ${item['totalSoldKg']} • Recaudado: ${item['totalRevenue']}',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${item['endedDate']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick reactivate button
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: primaryColor,
                            ),
                            tooltip: 'Reactivar Oferta',
                            onPressed: () {
                              _openEditDialog(item['rawProduct'] ?? item);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
