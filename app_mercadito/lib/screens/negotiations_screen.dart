import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';


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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por Rol',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('Todos'),
              _buildFilterOption('Comprador'),
              _buildFilterOption('Proveedor'),
              const SizedBox(height: 24),
              Text(
                'Filtrar por Fecha',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF00462f)),
                title: Text(
                  _selectedDate != null 
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Seleccionar Fecha',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: _selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                          Navigator.pop(context);
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0C6648),
                            onPrimary: Colors.white,
                            onSurface: Color(0xFF181d1a),
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String role) {
    return ListTile(
      title: Text(
        role,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: _roleFilter == role ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: _roleFilter == role ? const Icon(Icons.check, color: Color(0xFF00462f)) : null,
      onTap: () {
        setState(() {
          _roleFilter = role;
        });
        Navigator.pop(context);
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores basados en el HTML
    final surfaceColor = isDark ? const Color(0xFF181d1a) : const Color(0xFFf7faf5);
    final surfaceContainerColor = isDark ? const Color(0xFF1c2c26) : const Color(0xFFebefea);
    final surfaceContainerLowColor = isDark ? const Color(0xFF15221d) : const Color(0xFFf1f4f0);
    final surfaceContainerLowestColor = isDark ? const Color(0xFF0f1613) : const Color(0xFFffffff);
    
    final primaryColor = isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f);
    final onSurfaceColor = isDark ? const Color(0xFFe0e3df) : const Color(0xFF181d1a);
    final onSurfaceVariantColor = isDark ? const Color(0xFFbec9c1) : const Color(0xFF3f4943);
    final secondaryColor = isDark ? const Color(0xFFafcebb) : const Color(0xFF486456);
    final outlineVariantColor = isDark ? const Color(0xFF4e6b5b) : const Color(0xFFbec9c1);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: isDark ? surfaceColor : surfaceContainerLowColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Negociaciones',
          style: GoogleFonts.plusJakartaSans(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF036042),
              child: const Icon(Icons.handshake, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceContainerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? surfaceContainerLowestColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Pendientes',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.w600,
                                color: _selectedTabIndex == 0 ? primaryColor : onSurfaceVariantColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? surfaceContainerLowestColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Completadas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.w600,
                                color: _selectedTabIndex == 1 ? primaryColor : onSurfaceVariantColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 2 ? surfaceContainerLowestColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 2
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Canceladas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _selectedTabIndex == 2 ? FontWeight.bold : FontWeight.w600,
                                color: _selectedTabIndex == 2 ? primaryColor : onSurfaceVariantColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search & Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Buscar producto o comprador...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: onSurfaceVariantColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.search, color: onSurfaceVariantColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceContainerLowColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: (_roleFilter != 'Todos' || _selectedDate != null) ? primaryColor : onSurfaceColor),
                      onPressed: _showFilterDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section Title
              Text(
                'Solicitudes Recientes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Negotiation Cards list
              if (_selectedTabIndex == 0)
                if (_filteredPending.isEmpty)
                  _buildEmptyState(
                    context: context,
                    icon: Icons.inbox,
                    title: 'No hay negociaciones pendientes',
                    message: 'Actualmente no tienes solicitudes de negociación activas.',
                    primaryColor: primaryColor,
                    onSurfaceVariantColor: onSurfaceVariantColor,
                  )
                else
                  ..._filteredPending.map((negotiation) => _buildNegotiationCard(
                      context: context,
                      negotiation: negotiation,
                      isDark: isDark,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      outlineVariantColor: outlineVariantColor,
                      onSurfaceColor: onSurfaceColor,
                      secondaryColor: secondaryColor,
                      surfaceContainerColor: surfaceContainerColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                      primaryColor: primaryColor,
                      onCancel: () {
                        _showCancelNegotiationBottomSheet(
                          context: context,
                          negotiation: negotiation,
                          onConfirmCancel: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('La negociación ha sido cancelada.'),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          },
                        );
                      },
                      onFinalize: () {
                        final nextId = generateNextInvoiceId();
                        setState(() {
                          mockNegotiations.remove(negotiation);
                          mockCompletedNegotiations.insert(0, {
                            'invoice_id': nextId,
                            'product': negotiation['product'],
                            'buyer': negotiation['buyer'],
                            'role': negotiation['role'],
                            'date': 'Justo ahora',
                            'price': '\$50.00 / kg', // Mock
                            'quantity': '100 kg', // Mock
                            'image': negotiation['image'],
                          });
                          _selectedTabIndex = 1;
                        });

                        // Synchronize with global order history
                        final currentOrders = List<Map<String, dynamic>>.from(globalOrders.value);
                        currentOrders.insert(0, {
                          'id': nextId,
                          'invoice_no': nextId,
                          'title': negotiation['product'],
                          'price': '\$50.00',
                          'seller': negotiation['buyer'] ?? 'Comprador Anónimo',
                          'date': 'Hoy, justo ahora',
                          'status': 'Entregado',
                          'imageUrl': negotiation['image'],
                          'payment_method': 'Efectivo contra entrega',
                          'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
                          'quantity_label': '100 kg',
                          'initial_price': '\$50.00 / kg',
                          'final_price': '\$50.00 / kg',
                          'items': [
                            {
                              'name': negotiation['product'],
                              'quality': 'Primera Calidad',
                              'price': '\$50.00',
                              'quantity': 100,
                              'unit': 'kg',
                              'img': negotiation['image']
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
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      },
                    ))
              else if (_selectedTabIndex == 1)
                if (_filteredCompleted.isEmpty)
                  _buildEmptyState(
                    context: context,
                    icon: Icons.history,
                    title: 'No hay negociaciones completadas',
                    message: 'Aún no has completado ninguna negociación.',
                    primaryColor: primaryColor,
                    onSurfaceVariantColor: onSurfaceVariantColor,
                  )
                else
                  ..._filteredCompleted.map((negotiation) => _buildCompletedCard(
                      context: context,
                      negotiation: negotiation,
                      isDark: isDark,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      outlineVariantColor: outlineVariantColor,
                      onSurfaceColor: onSurfaceColor,
                      secondaryColor: secondaryColor,
                      surfaceContainerColor: surfaceContainerColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                      primaryColor: primaryColor,
                    ))
              else
                if (_filteredCancelled.isEmpty)
                  _buildEmptyState(
                    context: context,
                    icon: Icons.cancel_outlined,
                    title: 'No hay negociaciones canceladas',
                    message: 'No tienes registro de negociaciones canceladas.',
                    primaryColor: primaryColor,
                    onSurfaceVariantColor: onSurfaceVariantColor,
                  )
                else
                  ..._filteredCancelled.map((negotiation) => _buildCancelledCard(
                      context: context,
                      negotiation: negotiation,
                      isDark: isDark,
                      surfaceContainerLowestColor: surfaceContainerLowestColor,
                      outlineVariantColor: outlineVariantColor,
                      onSurfaceColor: onSurfaceColor,
                      secondaryColor: secondaryColor,
                      surfaceContainerColor: surfaceContainerColor,
                      onSurfaceVariantColor: onSurfaceVariantColor,
                      surfaceContainerLowColor: surfaceContainerLowColor,
                      primaryColor: primaryColor,
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNegotiationCard({
    required BuildContext context,
    required Map<String, dynamic> negotiation,
    required bool isDark,
    required Color surfaceContainerLowestColor,
    required Color outlineVariantColor,
    required Color onSurfaceColor,
    required Color secondaryColor,
    required Color surfaceContainerColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowColor,
    required Color primaryColor,
    required VoidCallback onCancel,
    required VoidCallback onFinalize,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/chat-detail');
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.3)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(negotiation['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
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
                                negotiation['product'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: onSurfaceColor,
                                ),
                              ),
                              Text(
                                '${negotiation['buyer']} • ${negotiation['role'] ?? 'Comprador'}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: surfaceContainerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            negotiation['date'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariantColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Message Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        negotiation['message'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showActionConfirmationDialog(
                  context: context,
                  title: '¿Cancelar negociación?',
                  message: 'La negociación será cancelada.',
                  confirmText: 'Si, Continuar',
                  confirmColor: const Color(0xFFD32F2F),
                  onConfirm: () {
                    onCancel();
                  },
                  isDark: isDark,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEAEA).withValues(alpha: 0.85),
                  foregroundColor: const Color(0xFFD32F2F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 52),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showActionConfirmationDialog(
                  context: context,
                  title: '¿Finalizar negociación?',
                  message: 'La negociación será cerrada y marcada como completada.',
                  confirmText: 'Si, Continuar',
                  confirmColor: const Color(0xFF0C6648),
                  onConfirm: () {
                    onFinalize();
                  },
                  isDark: isDark,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C6648).withValues(alpha: 0.85),
                  foregroundColor: const Color(0xFFFBFCFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 52),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Finalizar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildCompletedCard({
    required BuildContext context,
    required Map<String, dynamic> negotiation,
    required bool isDark,
    required Color surfaceContainerLowestColor,
    required Color outlineVariantColor,
    required Color onSurfaceColor,
    required Color secondaryColor,
    required Color surfaceContainerColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowColor,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surfaceContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(negotiation['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negotiation['product'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: onSurfaceColor,
                      ),
                    ),
                    Text(
                      '${negotiation['buyer']} • ${negotiation['role'] ?? 'Comprador'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFcaead7).withValues(alpha: 0.5), // secondary-container / 50
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFF4e6b5b)), // on-secondary-container
                        const SizedBox(width: 4),
                        Text(
                          'CERRADA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: const Color(0xFF4e6b5b),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    negotiation['date'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price and Quantity Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceContainerLowColor,
              borderRadius: BorderRadius.circular(8),
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
                        fontSize: 12,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      negotiation['price'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
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
                        fontSize: 12,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      negotiation['quantity'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Ver Detalle Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  context.push('/negotiation-detail', extra: negotiation);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver Detalle',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 18, color: primaryColor),
                  ],
                ),
              ),
            ],
          ),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1c2c26) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF181d1a),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      height: 1.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'No',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.2,
                              color: isDark ? Colors.white38 : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            confirmText,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required Color primaryColor,
    required Color onSurfaceVariantColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: onSurfaceVariantColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard({
    required BuildContext context,
    required Map<String, dynamic> negotiation,
    required bool isDark,
    required Color surfaceContainerLowestColor,
    required Color outlineVariantColor,
    required Color onSurfaceColor,
    required Color secondaryColor,
    required Color surfaceContainerColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowColor,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariantColor.withValues(alpha: 0.15)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surfaceContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(negotiation['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      negotiation['product'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: onSurfaceColor,
                      ),
                    ),
                    Text(
                      '${negotiation['buyer']} • ${negotiation['role'] ?? 'Comprador'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel, size: 14, color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F)),
                        const SizedBox(width: 4),
                        Text(
                          'CANCELADA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Request and Cancel Dates Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitado: ${negotiation['requestDate']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariantColor,
                ),
              ),
              Text(
                'Cancelado: ${negotiation['cancelDate']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Price and Quantity Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceContainerLowColor,
              borderRadius: BorderRadius.circular(8),
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
                        fontSize: 12,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      '${negotiation['price']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                        fontSize: 12,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      '${negotiation['quantity']} (${negotiation['saleType']})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Reason box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF231717) : const Color(0xFFFFF6F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF4C2A2A) : const Color(0xFFFFE3E3)),
            ),
            child: Text(
              'Motivo: ${negotiation['reason']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB71C1C),
              ),
            ),
          ),
          if (negotiation['comments'] != null && negotiation['comments'].toString().isNotEmpty) ...[
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
                    size: 18
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          negotiation['role'] == 'Proveedor' ? 'NOTA DEL PROVEEDOR' : 'NOTA DEL COMPRADOR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB71C1C),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${negotiation['comments']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
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

  void _showCancelNegotiationBottomSheet({
    required BuildContext context,
    required Map<String, dynamic> negotiation,
    required VoidCallback onConfirmCancel,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181d1a) : const Color(0xFFf7faf5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFffdad6) : const Color(0xFF93000a),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lamentamos que la negociación no haya concluido. Por favor, ayúdanos a entender el motivo.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Product Preview Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f1613) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(negotiation['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRODUCTO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                negotiation['product'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? (isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f))
                                      : (isDark ? Colors.white30 : Colors.black26),
                                  width: isSelected ? 6 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reason,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? (isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f))
                                    : (isDark ? Colors.grey[300] : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Comments area header with character counter and mandatory label
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
                                isCommentRequired ? 'Cuéntanos más (Obligatorio)*' : 'Cuéntanos más (Opcional)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCommentRequired 
                                      ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A))
                                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                ),
                              ),
                              Text(
                                '$currentLength/500',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0f1613) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCommentRequired && currentLength < 28
                                    ? (isDark ? const Color(0xFFBA1A1A) : const Color(0xFFFFDAD6))
                                    : (isDark ? Colors.white12 : Colors.grey[200]!),
                                width: isCommentRequired && currentLength < 28 ? 1.5 : 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: commentsController,
                              maxLines: 3,
                              maxLength: 500,
                              onChanged: (text) {
                                setModalState(() {});
                              },
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: isCommentRequired 
                                    ? 'Por favor, detalle el motivo (mínimo 28 caracteres)...' 
                                    : 'Cuéntanos más...',
                                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 13),
                                contentPadding: const EdgeInsets.all(12),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                          if (isCommentRequired && currentLength < 28) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded, 
                                  color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A), 
                                  size: 14
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Por favor brinde más detalles (faltan ${28 - currentLength} caracteres).',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons
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
                          
                          // Add to Cancelled Negotiations list
                          setState(() {
                            mockNegotiations.remove(negotiation);
                            mockCancelledNegotiations.insert(0, {
                              'product': negotiation['product'],
                              'buyer': negotiation['buyer'],
                              'role': negotiation['role'],
                              'requestDate': negotiation['date'],
                              'cancelDate': 'Justo ahora',
                              'price': '\$22.00 / caja', // Mocked price/quantity
                              'quantity': '20',
                              'saleType': 'caja',
                              'reason': finalReason,
                              'comments': commentsController.text,
                              'image': negotiation['image'],
                            });
                            _selectedTabIndex = 2; // Auto-switch to Cancelled tab!
                          });
                          
                          onConfirmCancel();
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled ? const Color(0xFFba1a1a) : (isDark ? Colors.white12 : Colors.black12),
                          foregroundColor: isButtonEnabled ? Colors.white : (isDark ? Colors.white30 : Colors.black38),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmar Cancelación',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Volver',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
