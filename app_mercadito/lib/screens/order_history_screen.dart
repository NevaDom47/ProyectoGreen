import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/global_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos'; // 'Todos', 'Pendientes', 'Completados', 'Cancelados'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Agrarian Colors from code.txt / DESIGN.md
    final bgColor = isDark ? const Color(0xFF0a110e) : const Color(0xFFf7faf5);
    final surfaceColor = isDark ? const Color(0xFF15221d) : Colors.white;

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
                  color: isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white70 : const Color(0xFF486456),
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
            color: Color(0xFF00462f),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 52), // Spacer to balance leading button size
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalOrders,
          builder: (context, orders, child) {
            // Calculate metrics dynamically
            double totalSpent = 0;
            int pendingCount = 0;
            int completedCount = 0;

            for (var order in orders) {
              final status = order['status'] as String;
              if (status == 'Entregado') {
                completedCount++;
                final totalStr = order['total'].toString().replaceAll('\$', '');
                totalSpent += double.tryParse(totalStr) ?? 0.0;
              } else if (status == 'En camino') {
                pendingCount++;
              }
            }

            // Filter orders based on query and status selection
            final filteredOrders = orders.where((order) {
              final title = (order['title'] ?? '').toString().toLowerCase();
              final seller = (order['seller'] ?? '').toString().toLowerCase();
              final status = (order['status'] ?? '').toString();

              final matchesSearch = title.contains(_searchQuery.toLowerCase()) || 
                                    seller.contains(_searchQuery.toLowerCase());

              bool matchesStatus = true;
              if (_selectedStatus == 'Pendientes') {
                matchesStatus = status == 'En camino';
              } else if (_selectedStatus == 'Completados') {
                matchesStatus = status == 'Entregado';
              } else if (_selectedStatus == 'Cancelados') {
                matchesStatus = status == 'Cancelado';
              }

              return matchesSearch && matchesStatus;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Editorial Header block
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
                            color: Color(0xFF181d1a),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revisa tus compras y negociaciones pasadas.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF3f4943),
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
                    child: _buildMetricsRow(theme, isDark, totalSpent, pendingCount, completedCount),
                  ),
                ),

                // Search and Filters Sticky-like background
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
                              color: const Color(0xFF00462f).withValues(alpha: isDark ? 0.3 : 0.15),
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
                              onTap: () => _showOrderDetailsBottomSheet(context, theme, isDark, order),
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
    double totalSpent,
    int pendingCount,
    int completedCount,
  ) {
    final cardBgColor = isDark ? const Color(0xFF15221d) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22352d) : const Color(0xFFbec9c1).withValues(alpha: 0.15);

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Completados',
            '$completedCount',
            Icons.task_alt,
            const Color(0xFF4e6b5b),
            isDark,
            cardBgColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            'Pendientes',
            '$pendingCount',
            Icons.hourglass_empty,
            Colors.orange[800]!,
            isDark,
            cardBgColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricItem(
            'Invertido',
            '\$${totalSpent.toStringAsFixed(1)}',
            Icons.monetization_on,
            const Color(0xFF00462f),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF181d1a),
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
              color: isDark ? Colors.grey[500] : const Color(0xFF486456),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    final searchBgColor = isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: searchBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.white60 : const Color(0xFF486456),
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
                color: isDark ? Colors.white : const Color(0xFF181d1a),
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por producto o proveedor...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: isDark ? Colors.grey[600] : const Color(0xFF486456).withValues(alpha: 0.6),
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
                color: isDark ? Colors.grey[600] : const Color(0xFF486456),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    final statuses = ['Todos', 'Pendientes', 'Completados', 'Cancelados'];
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

          final activeColor = const Color(0xFF00462f);
          final activeText = Colors.white;
          final inactiveColor = isDark ? const Color(0xFF15221d) : Colors.white;
          final inactiveText = isDark ? Colors.grey[400]! : const Color(0xFF486456);
          final borderColor = isDark 
              ? const Color(0xFF22352d) 
              : const Color(0xFFbec9c1).withValues(alpha: 0.3);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected ? Colors.transparent : borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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

  void _showOrderDetailsBottomSheet(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> order,
  ) {
    final String status = order['status'] ?? 'Entregado';
    final List itemsList = order['items'] as List? ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a110e) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Pull handler
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (status != 'Cancelado')
                              Text(
                                order['id'] ?? '#ORD-00000',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00462f),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            const SizedBox(height: 2),
                            const Text(
                              'Detalle de la Negociación',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF181d1a),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF486456)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // Live shipment tracking timeline
                          _buildTrackingTimeline(theme, isDark, status),
                          const SizedBox(height: 24),
                          
                          // Vendor Section
                          _buildSectionTitle('Vendedor'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF00462f).withValues(alpha: 0.1),
                                foregroundColor: const Color(0xFF00462f),
                                radius: 18,
                                child: const Icon(Icons.agriculture, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  order['seller'] ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF181d1a),
                                  ),
                                ),
                              ),
                              const Icon(Icons.verified, size: 16, color: Color(0xFF00462f)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Products Section
                          _buildSectionTitle('Productos'),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemsList.length,
                            itemBuilder: (context, idx) {
                              final item = itemsList[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(item['img'] ?? 'https://via.placeholder.com/150'),
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
                                            item['name'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : const Color(0xFF181d1a),
                                            ),
                                          ),
                                          Text(
                                            'Cant: ${item['quantity']} (${item['unit']}) • ${item['quality']}',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      item['price'] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF181d1a),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Invoice pricing summary
                          _buildSectionTitle('Resumen de Cobro'),
                          const SizedBox(height: 8),
                          _buildBillingRow('Subtotal', order['subtotal'] ?? '', isDark),
                          const SizedBox(height: 4),
                          _buildBillingRow('Costo de envío', order['delivery_fee'] ?? '', isDark),
                          const SizedBox(height: 6),
                          Container(
                            height: 1,
                            color: isDark ? const Color(0xFF22352d) : const Color(0xFFbec9c1).withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Negociado',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF181d1a),
                                ),
                              ),
                              Text(
                                order['total'] ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00462f),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Shipping coordinate detail rows
                          _buildSectionTitle('Detalles de Envío y Pago'),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.location_on_outlined, 'Dirección de entrega', order['shipping_address'] ?? '', isDark),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.payment_outlined, 'Método de Pago', order['payment_method'] ?? '', isDark),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  
                  // Sticky bottom sheet buttons panel
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00462f),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.replay, size: 18),
                                label: const Text(
                                  'Volver a comprar',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleReorder(context, order);
                                },
                              ),
                            ),
                          ],
                        ),
                        // Only show rating button for completed items, never show invoice options for cancelled items
                        if (status != 'Cancelado') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Ratings button
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(
                                      color: status == 'Entregado' 
                                          ? const Color(0xFF00462f) 
                                          : (isDark ? const Color(0xFF22352d) : Colors.grey[300]!),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.star_outline,
                                    size: 18,
                                    color: status == 'Entregado' ? const Color(0xFF00462f) : Colors.grey[400],
                                  ),
                                  label: Text(
                                    'Calificar Pedido',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'Entregado' ? const Color(0xFF00462f) : Colors.grey[400],
                                    ),
                                  ),
                                  onPressed: status == 'Entregado' ? () {
                                    Navigator.pop(context);
                                    _showRatingDialog(context, theme, isDark, order);
                                  } : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Invoices button (PDF download only available if not cancelled)
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: Color(0xFF00462f)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Color(0xFF00462f)),
                                  label: const Text(
                                    'Descargar Factura',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00462f),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _handleDownloadInvoice(context, order);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Color(0xFF00462f),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            color: isDark ? Colors.white30 : const Color(0xFF486456),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF181d1a),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF486456)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10, 
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF181d1a),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline(ThemeData theme, bool isDark, String status) {
    int activeIndex = 0;
    if (status == 'En camino') {
      activeIndex = 2;
    } else if (status == 'Entregado') {
      activeIndex = 3;
    } else if (status == 'Cancelado') {
      activeIndex = -1;
    } else {
      activeIndex = 1;
    }

    if (activeIndex == -1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFffdad6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Color(0xFFba1a1a), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Esta negociación fue cancelada y no pudo completarse.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93000a),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final List<Map<String, dynamic>> stages = [
      {'title': 'Recibido', 'subtitle': 'Confirmado'},
      {'title': 'En preparación', 'subtitle': 'Empacando'},
      {'title': 'Pendiente', 'subtitle': 'Transporte'},
      {'title': 'Entregado', 'subtitle': 'Entregado'},
    ];

    final timelineBgColor = isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: timelineBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_outlined, color: Color(0xFF00462f), size: 16),
              const SizedBox(width: 8),
              Text(
                status == 'En camino' ? 'SEGUIMIENTO DE NEGOCIACIÓN (PENDIENTE)' : 'SEGUIMIENTO DE NEGOCIACIÓN',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white70 : const Color(0xFF181d1a),
                  letterSpacing: 0.8,
                ),
              ),
              if (status == 'En camino') ...[
                const SizedBox(width: 8),
                _PulseIndicator(),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (idx) {
              final isCompleted = idx <= activeIndex;
              final isCurrent = idx == activeIndex;
              final color = isCompleted ? const Color(0xFF00462f) : (isDark ? const Color(0xFF22352d) : Colors.grey[300]!);

              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted ? color : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : Text(
                                    '${idx + 1}',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stages[idx]['title']!,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? const Color(0xFF00462f)
                                : (isCompleted ? (isDark ? Colors.white60 : Colors.black54) : Colors.grey),
                          ),
                        ),
                        Text(
                          stages[idx]['subtitle']!,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8, 
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (idx < stages.length - 1)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            height: 2,
                            color: idx < activeIndex ? const Color(0xFF00462f) : (isDark ? const Color(0xFF22352d) : Colors.grey[300]!),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> order) {
    double stars = 5.0;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF15221d) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Calificar Vendedor',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF181d1a),
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Cómo calificarías tu compra con "${order['seller']}"?',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF486456),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Stars row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (idx) {
                      final hasStar = idx < stars;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            stars = idx + 1.0;
                          });
                        },
                        child: Icon(
                          hasStar ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Commentary box
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF22352d) : const Color(0xFFbec9c1).withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: textController,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13, 
                        color: isDark ? Colors.white : const Color(0xFF181d1a),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu opinión aquí (opcional)...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[500])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00462f),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¡Gracias por calificar tu compra! Tu opinión nos ayuda a crecer.',
                                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF00462f),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: const Text(
                    'Enviar reseña', 
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleReorder(BuildContext context, Map<String, dynamic> order) {
    final List itemsList = order['items'] as List? ?? [];
    if (itemsList.isEmpty) return;

    for (var item in itemsList) {
      final productMap = {
        'name': item['name'] ?? order['title'],
        'supplier': order['seller'],
        'price': item['price'] ?? order['price'],
        'unit': item['unit'] ?? 'unidad',
        'quality': item['quality'] ?? 'Primera Calidad',
        'image': item['img'] ?? order['imageUrl'],
      };
      addToCart(productMap);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Se agregaron los productos de este pedido al carrito!',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00462f),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: Colors.white,
          onPressed: () {
            context.push('/cart');
          },
        ),
      ),
    );
  }

  void _handleDownloadInvoice(BuildContext context, Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Descargando factura de ${order['title']} (${order['id']}).pdf...',
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// A premium interactive wrapper that implements the scale active visual tap feedback.
class InteractiveOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const InteractiveOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  State<InteractiveOrderCard> createState() => _InteractiveOrderCardState();
}

class _InteractiveOrderCardState extends State<InteractiveOrderCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String status = widget.order['status'] ?? 'Entregado';
    final String title = widget.order['title'] ?? '';
    final String seller = widget.order['seller'] ?? '';
    final String date = widget.order['date'] ?? '';
    final String invoiceNo = widget.order['invoice_no'] ?? widget.order['id'] ?? '';
    final String imageUrl = widget.order['imageUrl'] ?? 'https://via.placeholder.com/150';
    final String quantityLabel = widget.order['quantity_label'] ?? '1 unidad';
    
    final String initialPrice = widget.order['initial_price'] ?? widget.order['price'] ?? '';
    final String finalPrice = widget.order['final_price'] ?? widget.order['price'] ?? '';
    final String cancelReason = widget.order['cancel_reason'] ?? 'Sin acuerdo de precio';

    // Status Badge config matching code.txt specs
    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String badgeLabel;

    if (status == 'Cancelado') {
      badgeBg = const Color(0xFFffdad6);
      badgeText = const Color(0xFF93000a);
      badgeIcon = Icons.cancel;
      badgeLabel = 'Cancelado';
    } else if (status == 'En camino') {
      badgeBg = Colors.orange.withValues(alpha: 0.12);
      badgeText = Colors.orange[800]!;
      badgeIcon = Icons.hourglass_empty;
      badgeLabel = 'Pendiente';
    } else {
      badgeBg = const Color(0xFFcaead7);
      badgeText = const Color(0xFF4e6b5b);
      badgeIcon = Icons.check_circle;
      badgeLabel = 'Completado';
    }

    final cardBgColor = isDark ? const Color(0xFF15221d) : Colors.white;
    final borderColor = isDark 
        ? const Color(0xFF22352d) 
        : const Color(0xFFbec9c1).withValues(alpha: 0.2);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Top-right status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: badgeText, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          badgeLabel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8,
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
                      // Product Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Image frame with Glass overlay
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0f1815) : const Color(0xFFf1f4f0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // Quantity Overlay glass tag matching the HTML design specs
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      quantityLabel.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF00462f),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Right side: Info details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Metadata Uppercase block (Canceled items do not generate invoice receipts)
                                Text(
                                  status == 'Cancelado'
                                      ? date.toUpperCase()
                                      : '${date.toUpperCase()} • ${invoiceNo.toUpperCase()}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.grey[500] : const Color(0xFF486456),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Title with tight leading
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF181d1a),
                                    height: 1.15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Storefront Row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 14,
                                      color: isDark ? Colors.grey[500] : const Color(0xFF486456),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        seller,
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey[400] : const Color(0xFF486456),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Low-opacity tonal divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 16, bottom: 12),
                        color: isDark 
                            ? const Color(0xFF22352d) 
                            : const Color(0xFFbec9c1).withValues(alpha: 0.15),
                      ),

                      // Pricing Row details (with handshake or warning icon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left pricing block
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (status == 'Cancelado' ? 'PRECIO OFERTADO' : 'PRECIO UNITARIO INICIAL').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.grey[500] : const Color(0xFF486456),
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
                                  color: isDark ? Colors.grey[400] : const Color(0xFF486456),
                                  decoration: status == 'Cancelado' 
                                      ? null 
                                      : TextDecoration.lineThrough,
                                  decorationColor: const Color(0xFFba1a1a).withValues(alpha: 0.6),
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
                                (status == 'Cancelado' ? 'MOTIVO' : 'PRECIO FINAL NEGOCIADO').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: status == 'Cancelado' 
                                      ? const Color(0xFF682826) 
                                      : const Color(0xFF00462f),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (status == 'Cancelado')
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 14,
                                      color: Color(0xFF682826),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cancelReason,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF682826),
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
                                      color: Color(0xFF00462f),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      finalPrice,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF00462f),
                                      ),
                                    ),
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
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
