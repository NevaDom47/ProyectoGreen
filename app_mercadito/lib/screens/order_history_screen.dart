import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? buyer;

  const OrderHistoryScreen({super.key, this.buyer});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos'; // 'Todos', 'Completados', 'Cancelados'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProduct(BuildContext context, Map<String, dynamic> order) {
    final isAvailable = order['is_available'] as bool? ?? (order['status'] != 'Cancelado');
    if (!isAvailable) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El producto "${order['title'] ?? 'seleccionado'}" no está disponible actualmente.',
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final productData = <String, dynamic>{
      'name': order['title'] ?? 'Producto',
      'title': order['title'] ?? 'Producto',
      'price': order['final_price'] ?? order['unit_price'] ?? order['price'] ?? '\$0.00',
      'img': order['imageUrl'] ?? '',
      'image': order['imageUrl'] ?? '',
      'supplier': order['seller'] ?? 'Proveedor',
      'provider': order['seller'] ?? 'Proveedor',
      'unit': order['unit'] ?? order['quantity_label'] ?? 'por KG',
      'rating': '4.9',
      'badge': 'PRIMERA CALIDAD',
      'salesMode': 'both',
    };

    context.push('/product_detail', extra: productData);
  }

  void _navigateToProvider(BuildContext context, String sellerName, [Map<String, dynamic>? order]) {
    Map<String, dynamic>? match;
    for (var p in globalFavoriteProviders.value) {
      if (p['name'] == sellerName) {
        match = p;
        break;
      }
    }

    final providerData = match ?? <String, dynamic>{
      'name': sellerName,
      'rating': '4.8',
      'sector': 'Sector San Pedro',
      'distance': 'A 5 km',
      'level': 'Nivel 3',
      'verified': true,
      'open': true,
      'sales': '1,240',
      'reviews': '120 reseñas',
      'traded': '1,240 productos negociados',
      'img': order?['imageUrl'] ?? 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
      'image': order?['imageUrl'] ?? 'https://eldinero.com.do/wp-content/uploads/mercados-productos-precios.jpg',
    };

    context.push('/provider', extra: providerData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1713) : const Color(0xFFF7FAF7);
    final surfaceColor = isDark ? const Color(0xFF16231D) : Colors.white;

    final buyerName = widget.buyer?['name'] as String?;

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
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0F1815) : const Color(0xFFF1F4F0),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white70 : const Color(0xFF016042),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Mercadito',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF016042),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 52),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalOrders,
          builder: (context, orders, child) {
            // Dynamic metrics: ONLY completed and cancelled
            double totalInvested = 0;
            int cancelledCount = 0;
            int completedCount = 0;

            for (var order in orders) {
              final status = (order['status'] ?? '').toString();
              if (status == 'Entregado' || status == 'Completado') {
                completedCount++;
                final totalStr = (order['total_price'] ?? order['subtotal'] ?? order['total'] ?? order['price'] ?? '0')
                    .toString()
                    .replaceAll('\$', '')
                    .split(' ')
                    .first
                    .trim();
                totalInvested += double.tryParse(totalStr) ?? 0.0;
              } else if (status == 'Cancelado') {
                cancelledCount++;
              }
            }

            // Filter orders (ONLY completed and cancelled)
            final filteredOrders = orders.where((order) {
              final status = (order['status'] ?? '').toString();
              final isCompleted = status == 'Entregado' || status == 'Completado';
              final isCancelled = status == 'Cancelado';

              if (!isCompleted && !isCancelled) return false;

              final title = (order['title'] ?? '').toString().toLowerCase();
              final seller = (order['seller'] ?? '').toString().toLowerCase();

              final matchesSearch = title.contains(_searchQuery.toLowerCase()) || 
                                    seller.contains(_searchQuery.toLowerCase());

              bool matchesStatus = true;
              if (_selectedStatus == 'Completados') {
                matchesStatus = isCompleted;
              } else if (_selectedStatus == 'Cancelados') {
                matchesStatus = isCancelled;
              }

              return matchesSearch && matchesStatus;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header block
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Histórico de Negociaciones',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181D1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          buyerName != null
                              ? 'Compras y negociaciones de $buyerName.'
                              : 'Revisa tus compras y negociaciones pasadas.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Metrics summary header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildMetricsRow(theme, isDark, totalInvested, cancelledCount, completedCount),
                  ),
                ),

                // Search and Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildSearchBar(isDark),
                        ),
                        const SizedBox(height: 12),
                        _buildFilterChips(theme, isDark),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Order history list
                if (filteredOrders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 54,
                              color: const Color(0xFF016042).withValues(alpha: isDark ? 0.3 : 0.15),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No se encontraron negociaciones',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Prueba con otra búsqueda o filtro.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = filteredOrders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InteractiveOrderCard(
                              order: order,
                              onProductTap: () => _navigateToProduct(context, order),
                              onProviderTap: () => _navigateToProvider(context, (order['seller'] ?? '').toString(), order),
                            ),
                          );
                        },
                        childCount: filteredOrders.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricsRow(
    ThemeData theme,
    bool isDark,
    double totalInvested,
    int cancelledCount,
    int completedCount,
  ) {
    final cardBgColor = isDark ? const Color(0xFF16231D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Completados',
            '$completedCount',
            Icons.task_alt_rounded,
            const Color(0xFF016042),
            isDark,
            cardBgColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            'Cancelados',
            '$cancelledCount',
            Icons.cancel_outlined,
            const Color(0xFFBA1A1A),
            isDark,
            cardBgColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            'Invertido',
            '\$${totalInvested.toStringAsFixed(1)}',
            Icons.monetization_on_outlined,
            const Color(0xFF016042),
            isDark,
            cardBgColor,
            borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
    Color cardBgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF181D1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    final searchBgColor = isDark ? const Color(0xFF16231D) : const Color(0xFFF1F4F0);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: searchBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.white60 : const Color(0xFF016042),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF181D1A),
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por producto o proveedor...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: Icon(
                Icons.cancel,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    // Only completed and cancelled
    final statuses = ['Todos', 'Completados', 'Cancelados'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status;

          const activeColor = Color(0xFF016042);
          const activeText = Colors.white;
          final inactiveColor = isDark ? const Color(0xFF16231D) : Colors.white;
          final inactiveText = isDark ? Colors.grey[400]! : const Color(0xFF475569);
          final borderColor = isDark 
              ? const Color(0xFF22382E) 
              : const Color(0xFFE2E8F0);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected ? Colors.transparent : borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? activeText : inactiveText,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A clean, interactive negotiation card with direct product and provider routing.
class InteractiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onProductTap;
  final VoidCallback onProviderTap;

  const InteractiveOrderCard({
    super.key,
    required this.order,
    required this.onProductTap,
    required this.onProviderTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String status = order['status'] ?? 'Entregado';
    final String title = order['title'] ?? '';
    final String seller = order['seller'] ?? '';
    final String date = order['date'] ?? '';
    final String invoiceNo = order['invoice_no'] ?? order['id'] ?? '';
    final String imageUrl = order['imageUrl'] ?? 'https://via.placeholder.com/150';
    final String quantityLabel = order['quantity_label'] ?? '1 unidad';
    
    final String initialPrice = order['initial_price'] ?? order['price'] ?? '';
    final String finalPrice = order['final_price'] ?? order['unit_price'] ?? order['price'] ?? '';
    final String totalPrice = order['total_price'] ?? order['subtotal'] ?? order['price'] ?? '';
    final String cancelReason = order['cancel_reason'] ?? 'Sin acuerdo de precio';

    final isCompleted = status == 'Entregado' || status == 'Completado';
    final badgeBg = isCompleted 
        ? const Color(0xFF016042).withValues(alpha: 0.1) 
        : const Color(0xFFBA1A1A).withValues(alpha: 0.1);
    final badgeText = isCompleted ? const Color(0xFF016042) : const Color(0xFFBA1A1A);
    final badgeIcon = isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final badgeLabel = isCompleted ? 'COMPLETADO' : 'CANCELADO';

    final cardBgColor = isDark ? const Color(0xFF16231D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Top-right status badge
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeText, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: badgeText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product & Seller Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto (interactiva)
                      GestureDetector(
                        onTap: onProductTap,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F1815) : const Color(0xFFF1F4F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // Right side: Info details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Metadata Uppercase block
                            Text(
                              isCompleted
                                  ? '${date.toUpperCase()} • ${invoiceNo.toUpperCase()}'
                                  : date.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Title (interactivo)
                            GestureDetector(
                              onTap: onProductTap,
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF181D1A),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Storefront Row (interactivo)
                            GestureDetector(
                              onTap: onProviderTap,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 14,
                                    color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      seller,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042),
                                        decoration: TextDecoration.underline,
                                        decorationColor: (isDark ? const Color(0xFF89d6b0) : const Color(0xFF016042)).withValues(alpha: 0.3),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Cantidad de producto negociada
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 13,
                                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Cantidad negociada: ',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  quantityLabel,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF181D1A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(top: 14, bottom: 12),
                    color: isDark ? const Color(0xFF22382E) : const Color(0xFFE2E8F0),
                  ),

                  // Pricing Row details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left pricing block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (isCompleted ? 'PRECIO UNITARIO INICIAL' : 'PRECIO OFERTADO').toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            initialPrice,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: const Color(0xFFBA1A1A).withValues(alpha: 0.6),
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ),

                      // Right pricing block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (isCompleted ? 'PRECIO FINAL NEGOCIADO' : 'MOTIVO').toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: isCompleted ? const Color(0xFF016042) : const Color(0xFFBA1A1A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (!isCompleted)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: Color(0xFFBA1A1A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cancelReason,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBA1A1A),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.handshake_outlined,
                                  size: 16,
                                  color: Color(0xFF016042),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  finalPrice,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF016042),
                                  ),
                                ),
                                if (totalPrice.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(Total: $totalPrice)',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
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
      ),
    );
  }
}
