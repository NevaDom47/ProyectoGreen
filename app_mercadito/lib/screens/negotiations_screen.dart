import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';
import '../theme/app_theme.dart';

class NegotiationsScreen extends StatefulWidget {
  const NegotiationsScreen({super.key});

  @override
  State<NegotiationsScreen> createState() => _NegotiationsScreenState();
}

class _NegotiationsScreenState extends State<NegotiationsScreen> {
  int _selectedTabIndex = 0; // 0 for Pendientes, 1 for Completadas, 2 for Canceladas
  String _searchQuery = '';
  String _roleFilter = 'Todos';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesDate(String dateStr) {
    if (_selectedDate == null) return true;
    if (dateStr == 'Justo ahora') {
      final now = DateTime.now();
      return _selectedDate!.year == now.year && _selectedDate!.month == now.month && _selectedDate!.day == now.day;
    }
    
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dayStr = _selectedDate!.day.toString().padLeft(2, '0');
    final formattedDate = '$dayStr ${months[_selectedDate!.month - 1]}';
    
    return dateStr.toLowerCase().contains(formattedDate.toLowerCase());
  }

  List<Map<String, dynamic>> get _filteredPending {
    return mockNegotiations.where((item) {
      final matchesSearch = (item['product'] as String).toLowerCase().contains(_searchQuery) ||
                            (item['buyer'] as String).toLowerCase().contains(_searchQuery);
      final matchesRole = _roleFilter == 'Todos' || item['role'] == _roleFilter;
      final matchesDate = _matchesDate(item['date'] as String);
      return matchesSearch && matchesRole && matchesDate;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredCompleted {
    return mockCompletedNegotiations.where((item) {
      final matchesSearch = (item['product'] as String).toLowerCase().contains(_searchQuery) ||
                            (item['buyer'] as String).toLowerCase().contains(_searchQuery);
      final matchesRole = _roleFilter == 'Todos' || item['role'] == _roleFilter;
      final matchesDate = _matchesDate(item['date'] as String);
      return matchesSearch && matchesRole && matchesDate;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredCancelled {
    return mockCancelledNegotiations.where((item) {
      final matchesSearch = (item['product'] as String).toLowerCase().contains(_searchQuery) ||
                            (item['buyer'] as String).toLowerCase().contains(_searchQuery);
      final matchesRole = _roleFilter == 'Todos' || item['role'] == _roleFilter;
      final matchesDate = _matchesDate(item['requestDate'] as String) || _matchesDate(item['cancelDate'] as String);
      return matchesSearch && matchesRole && matchesDate;
    }).toList();
  }

  void _showFilterDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filtrar por Rol',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilterOption('Todos', isDark, onSurfaceColor, borderColor),
              _buildFilterOption('Comprador', isDark, onSurfaceColor, borderColor),
              _buildFilterOption('Proveedor', isDark, onSurfaceColor, borderColor),
              const SizedBox(height: 20),
              Text(
                'Filtrar por Fecha',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.slate900 : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today_rounded,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    size: 20,
                  ),
                  title: Text(
                    _selectedDate != null 
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Seleccionar Fecha',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: _selectedDate != null ? FontWeight.w700 : FontWeight.w500,
                      color: onSurfaceColor,
                    ),
                  ),
                  trailing: _selectedDate != null 
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                            });
                            Navigator.pop(context);
                          },
                        )
                      : const Icon(Icons.chevron_right, size: 20),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primary,
                              onPrimary: Colors.white,
                              onSurface: onSurfaceColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String role, bool isDark, Color onSurfaceColor, Color borderColor) {
    final isSelected = _roleFilter == role;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF0F3628) : const Color(0xFFE8F5EE))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.primary : borderColor.withValues(alpha: 0.6),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        title: Text(
          role,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF89D6B0) : AppTheme.primary)
                : onSurfaceColor,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                size: 20,
              )
            : null,
        onTap: () {
          setState(() {
            _roleFilter = role;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  final List<Map<String, dynamic>> mockNegotiations = [
    {
      'product': 'Tomate Saladette',
      'buyer': 'Juan Pérez',
      'role': 'Comprador',
      'date': '14 Oct, 10:30 AM',
      'message': '"¿Podemos ajustar el precio por 50kg?"',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCp_n5G7_2I867ct5e-4CxrG4gpPtX8pmpapt4aGcC8xz68OZLjnNg-5DYRK132D7F3eX_k8BoG4fTReYFGRj3rY-Jjrh6CCKlFuVKrc2vK2Cck9xI0Bh53PEelQvXLDtOpF9uAcnzZm1oAuz3YQynfjH5mou2BHFGWgrCQ9iqS339N33AeUYKYqr0_eKPEZgei3hQHpOvVIxks814hCGYU1qVMPi8ITHHW9aOm4w38UTDu28jMg78JNyZO5acs0qcN-r2cIcfwCnw',
    },
    {
      'product': 'Aguacate Hass',
      'buyer': 'María García',
      'role': 'Proveedor',
      'date': '13 Oct, 04:15 PM',
      'message': '"Me interesa comprar el lote completo si hay descuento."',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC9dKnp_y_8GU6tHdoCtuiMB8r7xhLSO_EhoBQ3SgBFwConiY_XCZE6ZzktYB7aDhvyzRfqrik3cSYRCUrkGlExaT71igcG4DsOaJberIKM-FywWLEIq3nwVzKYGXLiAC_yO_f9XUgAkiD7fWMNHvsPTriBvcUIdnbxkiwuSUtkeEBge-A2yzyyt7vV1WkwwUTjCxoyHm49HQBNhhz1zdsJX6E135iYXXYZseNemHx7YTxxV2dlBaAotUYes08RHX0r7OxvU1ddjkM',
    },
    {
      'product': 'Limón Persa',
      'buyer': 'Carlos Ruiz',
      'role': 'Comprador',
      'date': '12 Oct, 09:00 AM',
      'message': '"¿Tienen disponibilidad para entrega mañana?"',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfOelLVxfc2Z5vEipAQdeiJXE5-zkfaCdzZ_kfJhVaYK3I_YiLKxl8WYn3e1CMuyRyQIMfHNANfO72pR_S-laYQcgXKce227Aklxxz-jOTMlRenPI_8_0yD0QauhZ9tcL1QPpkt98ZSt0q9vWn4OmkqcH4TdLNmtpKld3f5aK8QDtmjgWHQH6sUFo43Cr16qh-YCODh8Xxf6nPU8e1JGGzKOdTj02eHzd-Hr3AyDl29KqdMWbobtdeOQgEdq3F3ILWDQmcqSzvGwI',
    }
  ];

  final List<Map<String, dynamic>> mockCompletedNegotiations = [
    {
      'invoice_id': '#FAC-88290',
      'product': 'Tomates Cherry Orgánicos',
      'buyer': 'Juan Pérez',
      'role': 'Comprador',
      'date': '12 Oct 2023',
      'price': '\$45.00 / kg',
      'quantity': '150 kg',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB32zMtkIjodpTPfadClO6p0RBB_YGRBvqx5chQPmObhnrSPb8EnB0DOWn_4QJSrQWP665O6SUtHuucrWl9EaSJShWWYFW-WZ-Cy08SXOGW8rUfR_384bGdjGSAT9Ri12ICkNcX8y_nHzV2eedCwbqFqNwg11waXHrdS49xkxD02in2kJjXG-RfJTkFhN5CL5m9_n36-QZX8hnnOneKxuOCLIez6dwSb6W_VuVytqYxpa7MQlPVMlXVGMvz96ZI1JKij6hNHOWeuig',
    },
    {
      'invoice_id': '#FAC-88289',
      'product': 'Aguacate Hass Premium',
      'buyer': 'María Gómez',
      'role': 'Proveedor',
      'date': '05 Oct 2023',
      'price': '\$68.50 / kg',
      'quantity': '500 kg',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAED0sR_3E7lj3NxGReM6Ekx2ocYmfTZlJ8cQj7wyVr_pEOi4A27Aa6v5M81aG0YieKw3hGsQ-aR_xRYNseUt-4j3ZTTdjxBPfmCCkCm0q6ozYF6eZ_VN4tguI93G2rZNcJeEZv7v5nD8g41hlZvcUt9ckMjsX2iMVdnafVON52_UKuZfvCm1D3jUYevVB-paZbQxJf-8Vso3R0tDRClS_BRMU4IdrS9c7CQxClnAuynkN9f92UCNhlVhFIqbeNajOfkjVglzAu5cM',
    }
  ];

  final List<Map<String, dynamic>> mockCancelledNegotiations = [
    {
      'invoice_id': '#FAC-88288',
      'product': 'Tomate Saladette',
      'buyer': 'Juan Pérez',
      'role': 'Comprador',
      'requestDate': '14 Oct, 10:30 AM',
      'cancelDate': '24 May, 07:00 PM',
      'price': '\$18.50 / kg',
      'quantity': '100',
      'saleType': 'kg',
      'reason': 'Encontré un mejor precio',
      'comments': 'El comprador canceló porque consiguió una oferta directa a menor precio en la central.',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCp_n5G7_2I867ct5e-4CxrG4gpPtX8pmpapt4aGcC8xz68OZLjnNg-5DYRK132D7F3eX_k8BoG4fTReYFGRj3rY-Jjrh6CCKlFuVKrc2vK2Cck9xI0Bh53PEelQvXLDtOpF9uAcnzZm1oAuz3YQynfjH5mou2BHFGWgrCQ9iqS339N33AeUYKYqr0_eKPEZgei3hQHpOvVIxks814hCGYU1qVMPi8ITHHW9aOm4w38UTDu28jMg78JNyZO5acs0qcN-r2cIcfwCnw',
    },
    {
      'invoice_id': '#FAC-88287',
      'product': 'Limón Persa',
      'buyer': 'Carlos Ruiz',
      'role': 'Comprador',
      'requestDate': '12 Oct, 09:00 AM',
      'cancelDate': '24 May, 06:15 PM',
      'price': '\$22.00 / caja',
      'quantity': '20',
      'saleType': 'caja',
      'reason': 'El producto ya no está disponible',
      'comments': 'El proveedor no cuenta con stock suficiente en bodega para surtir las 20 cajas.',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfOelLVxfc2Z5vEipAQdeiJXE5-zkfaCdzZ_kfJhVaYK3I_YiLKxl8WYn3e1CMuyRyQIMfHNANfO72pR_S-laYQcgXKce227Aklxxz-jOTMlRenPI_8_0yD0QauhZ9tcL1QPpkt98ZSt0q9vWn4OmkqcH4TdLNmtpKld3f5aK8QDtmjgWHQH6sUFo43Cr16qh-YCODh8Xxf6nPU8e1JGGzKOdTj02eHzd-Hr3AyDl29KqdMWbobtdeOQgEdq3F3ILWDQmcqSzvGwI',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;
    final isFilterActive = _roleFilter != 'Todos' || _selectedDate != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.slate900 : const Color(0xFFF1F4F0),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppTheme.slate200 : AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Negociaciones',
          style: GoogleFonts.plusJakartaSans(
            color: onSurfaceColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F3628) : const Color(0xFFE8F5EE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E8262) : const Color(0xFFA5D6A7),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderColor,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Segmented Switcher Tabs
              _buildSegmentSwitcher(isDark, surfaceColor, borderColor, onSurfaceColor, secondaryTextColor),
              const SizedBox(height: 14),

              // Search Bar & Filter Button (Matching Mercado screen style)
              _buildSearchAndFilterRow(isDark, borderColor, isFilterActive),
              const SizedBox(height: 20),

              // Section Header
              Text(
                _selectedTabIndex == 0
                    ? 'Solicitudes Recientes'
                    : (_selectedTabIndex == 1 ? 'Acuerdos Concretados' : 'Negociaciones Canceladas'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 14),

              // Active Tab Content List
              if (_selectedTabIndex == 0)
                if (_filteredPending.isEmpty)
                  _buildEmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No hay negociaciones pendientes',
                    message: _searchQuery.isEmpty && !isFilterActive
                        ? 'Actualmente no tienes solicitudes de negociación activas.'
                        : 'No se encontraron resultados con los filtros actuales.',
                    isDark: isDark,
                    secondaryTextColor: secondaryTextColor,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredPending.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredPending[index];
                      return _buildNegotiationCard(
                        item: item,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        secondaryTextColor: secondaryTextColor,
                        borderColor: borderColor,
                        onCancel: () {
                          _showCancelNegotiationBottomSheet(
                            context: context,
                            negotiation: item,
                            onConfirmCancel: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('La negociación ha sido cancelada.'),
                                  backgroundColor: Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                          );
                        },
                        onFinalize: () {
                          final nextId = generateNextInvoiceId();
                          setState(() {
                            mockNegotiations.remove(item);
                            mockCompletedNegotiations.insert(0, {
                              'invoice_id': nextId,
                              'product': item['product'],
                              'buyer': item['buyer'],
                              'role': item['role'],
                              'date': 'Justo ahora',
                              'price': '\$50.00 / kg',
                              'quantity': '100 kg',
                              'image': item['image'],
                            });
                            _selectedTabIndex = 1;
                          });

                          // Synchronize with global order history
                          final currentOrders = List<Map<String, dynamic>>.from(globalOrders.value);
                          currentOrders.insert(0, {
                            'id': nextId,
                            'invoice_no': nextId,
                            'title': item['product'],
                            'price': '\$50.00',
                            'seller': item['buyer'] ?? 'Comprador Anónimo',
                            'date': 'Hoy, justo ahora',
                            'status': 'Entregado',
                            'imageUrl': item['image'],
                            'payment_method': 'Efectivo contra entrega',
                            'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
                            'quantity_label': '100 kg',
                            'initial_price': '\$50.00 / kg',
                            'final_price': '\$50.00 / kg',
                            'items': [
                              {
                                'name': item['product'],
                                'quality': 'Primera Calidad',
                                'price': '\$50.00',
                                'quantity': 100,
                                'unit': 'kg',
                                'img': item['image']
                              }
                            ],
                            'subtotal': '\$5,000.00',
                            'delivery_fee': '\$5.00',
                            'total': '\$5,005.00'
                          });
                          globalOrders.value = currentOrders;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Negociación finalizada y movida a Completadas.'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      );
                    },
                  )
              else if (_selectedTabIndex == 1)
                if (_filteredCompleted.isEmpty)
                  _buildEmptyState(
                    icon: Icons.history_rounded,
                    title: 'No hay negociaciones completadas',
                    message: 'Aún no has completado ninguna negociación con este criterio.',
                    isDark: isDark,
                    secondaryTextColor: secondaryTextColor,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCompleted.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredCompleted[index];
                      return _buildCompletedCard(
                        item: item,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        secondaryTextColor: secondaryTextColor,
                        borderColor: borderColor,
                      );
                    },
                  )
              else
                if (_filteredCancelled.isEmpty)
                  _buildEmptyState(
                    icon: Icons.cancel_outlined,
                    title: 'No hay negociaciones canceladas',
                    message: 'No tienes registro de negociaciones canceladas con este criterio.',
                    isDark: isDark,
                    secondaryTextColor: secondaryTextColor,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCancelled.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredCancelled[index];
                      return _buildCancelledCard(
                        item: item,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        secondaryTextColor: secondaryTextColor,
                        borderColor: borderColor,
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentSwitcher(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color onSurfaceColor,
    Color secondaryTextColor,
  ) {
    final activeBg = isDark ? AppTheme.slate700 : Colors.white;
    final inactiveText = isDark ? AppTheme.slate400 : AppTheme.slate500;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : const Color(0xFFE9EFEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Pendientes', mockNegotiations.length, activeBg, onSurfaceColor, inactiveText, isDark),
          _buildTabItem(1, 'Completadas', mockCompletedNegotiations.length, activeBg, onSurfaceColor, inactiveText, isDark),
          _buildTabItem(2, 'Canceladas', mockCancelledNegotiations.length, activeBg, onSurfaceColor, inactiveText, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    int index,
    String label,
    int count,
    Color activeBg,
    Color onSurfaceColor,
    Color inactiveText,
    bool isDark,
  ) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? onSurfaceColor : inactiveText,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.12)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: isSelected ? AppTheme.primaryLight : inactiveText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(bool isDark, Color borderColor, bool isFilterActive) {
    final searchBgColor = isDark ? const Color(0xFF1f2937) : const Color(0xFFE5F1EB);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: searchBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      hintText: 'Buscar producto o comprador...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _showFilterDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isFilterActive
                  ? (isDark ? const Color(0xFF0F3628) : const Color(0xFFE8F5EE))
                  : searchBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFilterActive
                    ? (isDark ? const Color(0xFF1E8262) : AppTheme.primary)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: isFilterActive
                      ? (isDark ? const Color(0xFF89D6B0) : AppTheme.primary)
                      : (isDark ? AppTheme.slate200 : AppTheme.slate700),
                  size: 20,
                ),
                if (isFilterActive)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNegotiationCard({
    required Map<String, dynamic> item,
    required bool isDark,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required VoidCallback onCancel,
    required VoidCallback onFinalize,
  }) {
    final messageBg = isDark ? AppTheme.slate900 : const Color(0xFFF6F8F6);

    return GestureDetector(
      onTap: () {
        context.push('/chat-detail');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
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
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                      child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceColor,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      item['role'] == 'Proveedor'
                                          ? Icons.storefront_outlined
                                          : Icons.person_outline_rounded,
                                      size: 13,
                                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${item['buyer']} • ${item['role'] ?? 'Comprador'}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.slate900 : const Color(0xFFF1F5F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['date'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Proposal message bubble
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: messageBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          item['message'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: onSurfaceColor.withValues(alpha: 0.85),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _showActionConfirmationDialog(
                    context: context,
                    title: '¿Cancelar negociación?',
                    message: 'La solicitud de negociación será cancelada y archivada.',
                    confirmText: 'Sí, Cancelar',
                    confirmColor: const Color(0xFFDC2626),
                    onConfirm: onCancel,
                    isDark: isDark,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF5C2424) : const Color(0xFFFECACA),
                    ),
                    backgroundColor: isDark ? const Color(0xFF2A1414) : const Color(0xFFFEF2F2),
                    foregroundColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showActionConfirmationDialog(
                    context: context,
                    title: '¿Finalizar negociación?',
                    message: 'La negociación será cerrada exitosamente y se generará la orden.',
                    confirmText: 'Sí, Finalizar',
                    confirmColor: AppTheme.primary,
                    onConfirm: onFinalize,
                    isDark: isDark,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 15, color: Colors.white),
                  label: const Text('Finalizar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard({
    required Map<String, dynamic> item,
    required bool isDark,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    final panelBg = isDark ? AppTheme.slate900 : const Color(0xFFF6F8F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
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
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item['image'],
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52,
                    height: 52,
                    color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Buyer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['product'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['buyer']} • ${item['role'] ?? 'Comprador'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D3224) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CERRADA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price and Quantity Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio Acordado',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['price'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cantidad Total',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['quantity'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Ver Detalle Action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  context.push('/negotiation-detail', extra: item);
                },
                icon: Text(
                  'Ver Detalle',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                  ),
                ),
                label: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard({
    required Map<String, dynamic> item,
    required bool isDark,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    final panelBg = isDark ? AppTheme.slate900 : const Color(0xFFF6F8F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
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
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item['image'],
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52,
                    height: 52,
                    color: isDark ? AppTheme.slate700 : AppTheme.slate200,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Buyer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['product'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['buyer']} • ${item['role'] ?? 'Comprador'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CANCELADA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Request and Cancel Dates Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitado: ${item['requestDate']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                'Cancelado: ${item['cancelDate']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Price and Quantity Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio Ofrecido',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['price']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cantidad',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['quantity']} (${item['saleType']})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reason Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF231717) : const Color(0xFFFFF6F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF4C2A2A) : const Color(0xFFFFE3E3)),
            ),
            child: Text(
              'Motivo: ${item['reason']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB71C1C),
              ),
            ),
          ),

          // Note if present
          if (item['comments'] != null && item['comments'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1515) : const Color(0xFFFFFDFD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF4C2A2A) : const Color(0xFFFFECEC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB71C1C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['role'] == 'Proveedor' ? 'NOTA DEL PROVEEDOR' : 'NOTA DEL COMPRADOR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB71C1C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item['comments']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: onSurfaceColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showActionConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
    required bool isDark,
  }) {
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.45,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'No, Volver',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        confirmText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool isDark,
    required Color secondaryTextColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.slate800 : const Color(0xFFE8F2EC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.slate100 : AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelNegotiationBottomSheet({
    required BuildContext context,
    required Map<String, dynamic> negotiation,
    required VoidCallback onConfirmCancel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.slate800 : Colors.white;
    final onSurfaceColor = isDark ? AppTheme.slate100 : AppTheme.slate900;
    final secondaryTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? AppTheme.slate700 : AppTheme.slate200;
    
    String selectedReason = 'Encontré un mejor precio';
    final TextEditingController commentsController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cancelar Negociación',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por favor, indícanos el motivo por el cual deseas cancelar esta solicitud.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Preview Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.slate900 : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              negotiation['image'],
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  negotiation['product'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                Text(
                                  '${negotiation['buyer']} • ${negotiation['role'] ?? 'Comprador'}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF89D6B0) : AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    // Reasons List
                    ...[
                      'Encontré un mejor precio',
                      'El producto ya no está disponible',
                      'Cambio de planes',
                      'Problemas con el proveedor',
                      'Otro (especificar)',
                    ].map((reason) {
                      final isSelected = selectedReason == reason;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedReason = reason;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppTheme.primary
                                        : (isDark ? Colors.white30 : Colors.black26),
                                    width: isSelected ? 5 : 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reason,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? onSurfaceColor : secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 12),
                    
                    // Comments Area
                    Builder(
                      builder: (context) {
                        final bool isCommentRequired = selectedReason == 'Problemas con el proveedor' || selectedReason == 'Otro (especificar)';
                        final int currentLength = commentsController.text.trim().length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isCommentRequired ? 'Detalles (Obligatorio)*' : 'Comentarios adicionales',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCommentRequired 
                                        ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFDC2626))
                                        : secondaryTextColor,
                                  ),
                                ),
                                Text(
                                  '$currentLength/500',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.slate900 : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCommentRequired && currentLength < 28
                                      ? (isDark ? const Color(0xFFBA1A1A) : const Color(0xFFFECACA))
                                      : borderColor,
                                ),
                              ),
                              child: TextField(
                                controller: commentsController,
                                maxLines: 3,
                                maxLength: 500,
                                onChanged: (text) {
                                  setModalState(() {});
                                },
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurfaceColor),
                                decoration: InputDecoration(
                                  hintText: isCommentRequired 
                                      ? 'Por favor, detalla el motivo (mínimo 28 caracteres)...' 
                                      : 'Escribe cualquier detalle adicional...',
                                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: secondaryTextColor),
                                  contentPadding: const EdgeInsets.all(12),
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                              ),
                            ),
                            if (isCommentRequired && currentLength < 28) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Faltan ${28 - currentLength} caracteres para el mínimo requerido.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFDC2626),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        );
                      }
                    ),
                    
                    const SizedBox(height: 18),
                    
                    // Action Buttons
                    Builder(
                      builder: (context) {
                        final bool isCommentRequired = selectedReason == 'Problemas con el proveedor' || selectedReason == 'Otro (especificar)';
                        final int currentLength = commentsController.text.trim().length;
                        final bool isButtonEnabled = !isCommentRequired || (currentLength >= 28 && currentLength <= 500);
                        
                        return ElevatedButton(
                          onPressed: isButtonEnabled ? () {
                            final finalReason = selectedReason == 'Otro (especificar)' 
                                ? (commentsController.text.isNotEmpty ? commentsController.text : 'Otro motivo')
                                : selectedReason;
                            
                            Navigator.pop(context);
                            
                            setState(() {
                              mockNegotiations.remove(negotiation);
                              mockCancelledNegotiations.insert(0, {
                                'product': negotiation['product'],
                                'buyer': negotiation['buyer'],
                                'role': negotiation['role'],
                                'requestDate': negotiation['date'],
                                'cancelDate': 'Justo ahora',
                                'price': '\$22.00 / caja',
                                'quantity': '20',
                                'saleType': 'caja',
                                'reason': finalReason,
                                'comments': commentsController.text,
                                'image': negotiation['image'],
                              });
                              _selectedTabIndex = 2; // Auto-switch to Cancelled tab
                            });
                            
                            onConfirmCancel();
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonEnabled ? const Color(0xFFDC2626) : (isDark ? Colors.white12 : Colors.black12),
                            foregroundColor: isButtonEnabled ? Colors.white : (isDark ? Colors.white30 : Colors.black38),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirmar Cancelación',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: Text(
                        'Volver',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
}
