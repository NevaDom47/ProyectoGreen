import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; 
import 'dart:ui';
import '../widgets/coupon_card.dart';
import '../data/global_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Data grouped by Vendor
  List<Map<String, dynamic>> get vendors => globalCart.value;

  void _notifyGlobalCart() {
    globalCart.value = List.from(vendors);
  }

  final Map<String, TextEditingController> _qtyControllers = {};
  
  // Coupon input controllers per vendor
  final Map<int, TextEditingController> _couponControllers = {};
  
  final Map<String, GlobalKey<ShakeWidgetState>> _shakeKeys = {};

  @override
  void initState() {
    super.initState();
    for (int v = 0; v < vendors.length; v++) {
      _couponControllers[v] = TextEditingController();
      for (int i = 0; i < (vendors[v]['items'] as List).length; i++) {
        vendors[v]['items'][i]['selected'] = true;
        _qtyControllers["${v}_$i"] = TextEditingController(text: vendors[v]['items'][i]['quantity'].toString());
      }
    }
  }

  void _removeItem(int vIndex, int iIndex) {
    setState(() {
      vendors[vIndex]['items'].removeAt(iIndex);
      if ((vendors[vIndex]['items'] as List).isEmpty) {
        vendors.removeAt(vIndex);
      }
    });
  }

  void _showPaymentOptions(BuildContext parentContext, int vIndex) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, currentMode, _) {
            final platformBrightness = MediaQuery.platformBrightnessOf(context);
            final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
            final surfaceColor = isDark ? const Color(0xFF171717) : const Color(0xFFffffff);
            final onSurface = isDark ? const Color(0xFFf1f5f9) : const Color(0xFF181d1a);
            final primaryColor = const Color(0xFF00462f);
            final outline = isDark ? const Color(0xFF64748b) : const Color(0xFF6f7a73);
            final outlineVariant = isDark ? const Color(0xFF475569) : const Color(0xFFbec9c1);

            final options = [
              'Efectivo contra entrega',
              'Tarjeta contra entrega',
              'Transferencia Bancaria'
            ];
            
            final currentSelection = vendors[vIndex]['payment_method'];

            return Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: outlineVariant, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 16),
                      Text('Método de Pago', style: TextStyle(color: onSurface, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
                      const SizedBox(height: 16),
                      ...options.map((option) {
                        bool isSelected = option == currentSelection;
                        return ListTile(
                          leading: Icon(
                            option.contains('Efectivo') ? Icons.payments_outlined : 
                            option.contains('Tarjeta') ? Icons.credit_card_outlined : Icons.account_balance_outlined, 
                            color: isSelected ? primaryColor : outline
                          ),
                          title: Text(option, style: TextStyle(color: onSurface, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
                          trailing: isSelected ? Icon(Icons.check_circle, color: primaryColor) : null,
                          onTap: () {
                            setState(() {
                              vendors[vIndex]['payment_method'] = option;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }
  void _showCouponOptions(BuildContext parentContext, int vIndex) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, currentMode, _) {
            final platformBrightness = MediaQuery.platformBrightnessOf(context);
            final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
            
            final bgColor = isDark ? const Color(0xFF0d1a15) : const Color(0xFFF8F6F6);
            final primaryColor = const Color(0xFF00462f);
            final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white; 
            final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
            final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF64748b);
            final borderColor = primaryColor.withOpacity(0.1);

            final outlineVariant = isDark ? const Color(0xFF475569) : const Color(0xFFbec9c1);
            final onSurface = isDark ? const Color(0xFFf1f5f9) : const Color(0xFF181d1a);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Handle
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cupones Disponibles', style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: surfaceColor,
                              child: Icon(Icons.close, color: subtextColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          CouponCard(
                            icon: Icons.local_grocery_store,
                            category: 'FRUTAS & VERDURAS',
                            discount: '15% OFF',
                            badge: 'NUEVO',
                            condition: 'Compra mínima \$20.000',
                            code: 'VERDE15',
                            expiry: '30 Oct 2023',
                            buttonLabel: 'Seleccionar',
                            buttonIcon: Icons.check_circle_outline,
                            bgColor: bgColor,
                            surfaceColor: surfaceColor,
                            primaryColor: primaryColor,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
                            onButtonTap: () {
                               setState(() {
                                 vendors[vIndex]['coupon'] = 'VERDE15';
                                 _couponControllers[vIndex]?.text = '';
                               });
                               Navigator.pop(ctx);
                            },
                          ),
                          const SizedBox(height: 16),
                          CouponCard(
                            icon: Icons.eco,
                            category: 'ORGÁNICOS',
                            discount: '\$5.000 DTO',
                            condition: 'En toda la tienda',
                            code: 'ORGANICOS',
                            expiry: '15 Nov 2023',
                            buttonLabel: 'Seleccionar',
                            buttonIcon: Icons.check_circle_outline,
                            bgColor: bgColor,
                            surfaceColor: surfaceColor,
                            primaryColor: primaryColor,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
                            onButtonTap: () {
                               setState(() {
                                 vendors[vIndex]['coupon'] = 'ORGANICOS';
                                 _couponControllers[vIndex]?.text = '';
                               });
                               Navigator.pop(ctx);
                            },
                          ),
                          const SizedBox(height: 16),
                          CouponCard(
                            icon: Icons.bakery_dining,
                            category: 'PANADERÍA',
                            discount: '2x1',
                            condition: 'Pan artesanal',
                            code: 'PAN2X1',
                            expiry: 'Mañana',
                            buttonLabel: 'Seleccionar',
                            buttonIcon: Icons.check_circle_outline,
                            bgColor: bgColor,
                            surfaceColor: surfaceColor,
                            primaryColor: primaryColor,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            borderColor: borderColor,
                            isFaded: true,
                            onButtonTap: () {
                               setState(() {
                                 vendors[vIndex]['coupon'] = 'PAN2X1';
                                 _couponControllers[vIndex]?.text = '';
                               });
                               Navigator.pop(ctx);
                            },
                          ),
                          const SizedBox(height: 24),
                          // Bento Style Promo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('¿Tienes un código?', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Text('Ingresa tu cupón', style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Icon(Icons.chevron_right, color: primaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // (Bottom action area removed)
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _couponControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(int vIndex, int iIndex, int newQty, [GlobalKey<ShakeWidgetState>? shakeKey]) {
    String currentUnit = vendors[vIndex]['items'][iIndex]['selected_unit'];
    var limits = _getUnitLimits(currentUnit);
    int min = limits['min']!;
    int max = limits['max']!;

    if (newQty < min || newQty == 0) { // Rule: 0 is not allowed, nor is anything below min
      newQty = min;
      shakeKey?.currentState?.shake();
    } else if (newQty > max) {
      newQty = max;
      shakeKey?.currentState?.shake();
    }

    setState(() {
      vendors[vIndex]['items'][iIndex]['quantity'] = newQty;
      _qtyControllers["${vIndex}_$iIndex"]?.text = newQty.toString();
      _qtyControllers["${vIndex}_$iIndex"]?.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyControllers["${vIndex}_$iIndex"]!.text.length));
    });
  }

  Color _getQualityColor(String quality) {
    if (quality.toLowerCase().contains('primera')) return const Color(0xFF10B981);
    if (quality.toLowerCase().contains('segunda')) return const Color(0xFFF59E0B);
    if (quality.toLowerCase().contains('tercera')) return const Color(0xFFEF4444);
    return Colors.grey;
  }

  Map<String, int> _getUnitLimits(String unit) {
    if (unit == 'UNIDAD') return {'min': 5, 'max': 20};
    if (unit == 'LIBRA') return {'min': 2, 'max': 50};
    if (unit == 'SACO') return {'min': 1, 'max': 10};
    if (unit == 'CAJA') return {'min': 1, 'max': 15};
    return {'min': 1, 'max': 99};
  }

  String _getLegend(String unit) {
    var limits = _getUnitLimits(unit);
    return 'Mín. ${limits['min']} | Máx. ${limits['max']}';
  }

  String _getPriceSuffix(String unit) {
    if (unit == 'UNIDAD') return 'c/u';
    if (unit == 'LIBRA') return '/ lb';
    if (unit == 'SACO') return '/ saco';
    if (unit == 'CAJA') return '/ caja';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final surfaceColor = isDark ? const Color(0xFF171717) : const Color(0xFFf7faf5); 
        final surfaceContainerLow = isDark ? const Color(0xFF262626) : const Color(0xFFf1f4f0);
        final surfaceContainerLowest = isDark ? const Color(0xFF1a1a1a) : const Color(0xFFffffff);
        final surfaceContainer = isDark ? const Color(0xFF404040) : const Color(0xFFebefea);
        
        final primaryColor = const Color(0xFF00462f);
        final primaryDark = const Color(0xFF34d399); 
        final onSurface = isDark ? const Color(0xFFf1f5f9) : const Color(0xFF181d1a);
        final secondary = isDark ? const Color(0xFF9ca3af) : const Color(0xFF486456);
        final outline = isDark ? const Color(0xFF64748b) : const Color(0xFF6f7a73);
        final outlineVariant = isDark ? const Color(0xFF475569) : const Color(0xFFbec9c1);
        final secondaryContainer = isDark ? const Color(0xFF1e3a8a) : const Color(0xFFcaead7);
        final onSecondaryContainer = isDark ? const Color(0xFFbae6fd) : const Color(0xFF4e6b5b);
        final tertiary = isDark ? const Color(0xFFf87171) : const Color(0xFF682826);
        
        final titleColor = isDark ? primaryDark : primaryColor;

        double subtotal = 0;
        double discountTotal = 0;
        int totalItemsCount = 0;
        
        for (var vendor in vendors) {
          double vendorSubtotal = 0;
          bool hasAnySelected = false;
          for (var item in vendor['items']) {
            if (item['selected'] == true) {
              double itemTotal = item['price_per_unit'] * item['quantity'];
              vendorSubtotal += itemTotal;
              subtotal += itemTotal;
              totalItemsCount++;
              hasAnySelected = true;
            }
          }
          if (hasAnySelected && vendor['coupon'] != null) {
            double discount = vendorSubtotal * 0.10; // 10% dummy discount
            discountTotal += discount;
          }
        }
        bool anySelected = totalItemsCount > 0;
        double deliveryFee = anySelected ? 2.50 : 0.0;
        double total = subtotal + deliveryFee - discountTotal;

        return Scaffold(
          backgroundColor: surfaceColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: titleColor),
              onPressed: () {
                if (context.canPop()) {
                   context.pop();
                } else {
                   context.go('/home');
                }
              },
            ),
            title: Text(
              'Confirma tu Negociación',
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Plus Jakarta Sans'),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor Groups
                ...vendors.asMap().entries.map((entry) {
                  int vIndex = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildVendorGroup(
                      vIndex, vendors[vIndex], 
                      surfaceColor, surfaceContainerLow, surfaceContainerLowest, surfaceContainer, 
                      primaryColor, onSurface, secondary, outline, outlineVariant, secondaryContainer, onSecondaryContainer, tertiary, isDark
                    ),
                  );
                }).toList(),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SUBTOTAL ($totalItemsCount items)', style: TextStyle(color: outline, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(color: onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TARIFA DE ENTREGA', style: TextStyle(color: outline, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          Text('\$${deliveryFee.toStringAsFixed(2)}', style: TextStyle(color: onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (discountTotal > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('DESCUENTOS', style: TextStyle(color: tertiary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            Text('-\$${discountTotal.toStringAsFixed(2)}', style: TextStyle(color: tertiary, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Divider(color: outlineVariant.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL ORDEN', style: TextStyle(color: onSurface, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      
                      const SizedBox(height: 24), // Dynamic spacing before button
                      
                      // Moved Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!anySelected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Por favor, selecciona al menos un producto para negociar.'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1e1e1e) : Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFcaead7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.receipt_long,
                                            size: 40,
                                            color: Color(0xFF00462f),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          '¿Confirmar Negociación?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Se generará un comprobante de negociación formal para los artículos seleccionados por un total de \$${total.toStringAsFixed(2)}.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 14,
                                            color: secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () => Navigator.pop(dialogContext),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                ),
                                                child: Text(
                                                  'CANCELAR',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontWeight: FontWeight.bold,
                                                    color: outline,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                  
                                                  // 1. Generate Invoice No
                                                  final nextId = generateNextInvoiceId();

                                                  // 2. Gather selected items
                                                  final List<Map<String, dynamic>> itemsList = [];
                                                  String firstItemTitle = '';
                                                  String firstItemImg = '';
                                                  String sellerName = 'Proveedor';

                                                  final List<Map<String, dynamic>> remainingCart = [];

                                                  for (var vendor in vendors) {
                                                    final List<Map<String, dynamic>> remainingItems = [];
                                                    for (var item in vendor['items']) {
                                                      if (item['selected'] == true) {
                                                        itemsList.add({
                                                          'name': item['name'],
                                                          'quality': item['quality'] ?? 'Primera Calidad',
                                                          'price': '\$${item['price_per_unit'].toStringAsFixed(2)}',
                                                          'quantity': item['quantity'],
                                                          'unit': item['selected_unit'] ?? 'unidad',
                                                          'img': item['img'] ?? '',
                                                        });
                                                        if (firstItemTitle.isEmpty) {
                                                          firstItemTitle = item['name'];
                                                          firstItemImg = item['img'] ?? '';
                                                          sellerName = vendor['name'] ?? 'Proveedor Local';
                                                        }
                                                      } else {
                                                        remainingItems.add(item);
                                                      }
                                                    }
                                                    if (remainingItems.isNotEmpty) {
                                                      final newVendor = Map<String, dynamic>.from(vendor);
                                                      newVendor['items'] = remainingItems;
                                                      remainingCart.add(newVendor);
                                                    }
                                                  }

                                                  // 3. Insert into global orders
                                                  final currentOrders = List<Map<String, dynamic>>.from(globalOrders.value);
                                                  currentOrders.insert(0, {
                                                    'id': nextId,
                                                    'invoice_no': nextId,
                                                    'title': firstItemTitle,
                                                    'price': '\$${subtotal.toStringAsFixed(2)}',
                                                    'seller': sellerName,
                                                    'date': 'Hoy, justo ahora',
                                                    'status': 'En camino',
                                                    'imageUrl': firstItemImg,
                                                    'payment_method': 'Efectivo contra entrega',
                                                    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
                                                    'quantity_label': '${itemsList.length} producto(s)',
                                                    'initial_price': '\$${subtotal.toStringAsFixed(2)}',
                                                    'final_price': '\$${subtotal.toStringAsFixed(2)}',
                                                    'items': itemsList,
                                                    'subtotal': '\$${subtotal.toStringAsFixed(2)}',
                                                    'delivery_fee': '\$${deliveryFee.toStringAsFixed(2)}',
                                                    'total': '\$${total.toStringAsFixed(2)}'
                                                  });
                                                  globalOrders.value = currentOrders;

                                                  // 4. Update cart
                                                  globalCart.value = remainingCart;

                                                  // 5. Show SnackBar
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Orden $nextId creada con éxito.'),
                                                      backgroundColor: const Color(0xFF00462f),
                                                    ),
                                                  );

                                                  // 6. Navigate to Order History
                                                  context.push('/order-history');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF00462f),
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'CONFIRMAR',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00462f),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            shadowColor: Colors.black45,
                            elevation: 4,
                          ),
                          label: const Text(
                            'NEGOCIAR COMPRA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                
                const SizedBox(height: 40), // Spacing below the summary card to breath
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildVendorGroup(
    int vIndex, Map<String, dynamic> vendor, 
    Color surfaceColor, Color surfaceLow, Color surfaceLowest, Color surfaceContainer, 
    Color primaryColor, Color onSurface, Color secondary, Color outline, Color outlineVariant, 
    Color secondaryContainer, Color onSecondaryContainer, Color tertiary, bool isDark) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vendor Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: (vendor['items'] as List).isNotEmpty && (vendor['items'] as List).every((i) => i['selected'] == true),
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(color: outlineVariant, width: 1.5),
                      onChanged: (val) {
                        setState(() {
                           for (var item in vendor['items']) {
                              item['selected'] = val ?? false;
                           }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => context.push('/provider', extra: vendor),
                      child: Text(vendor['name'], style: TextStyle(color: onSurface, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  if (vendor['isVerified']) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified, color: primaryColor, size: 18),
                  ]
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: secondaryContainer, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: onSecondaryContainer, size: 14),
                  const SizedBox(width: 4),
                  Text(vendor['delivery'], style: TextStyle(color: onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        
        // Products List
        ...vendor['items'].asMap().entries.map((entry) {
          int iIndex = entry.key;
          final item = vendor['items'][iIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: item['selected'] == true,
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: outlineVariant, width: 1.5),
                    onChanged: (val) {
                      setState(() {
                        item['selected'] = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProductCard(
                    vIndex, iIndex, vendor, 
                    surfaceLowest, surfaceLow, surfaceContainer, primaryColor, onSurface, secondary, outline, outlineVariant, tertiary, isDark
                  ),
                ),
              ],
            )
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProductCard(
    int vIndex, int iIndex, Map<String, dynamic> vendor, 
    Color surfaceLowest, Color surfaceLow, Color surfaceContainer, Color primaryColor, Color onSurface, 
    Color secondary, Color outline, Color outlineVariant, Color tertiary, bool isDark) {
    
    final item = vendor['items'][iIndex];
    bool showPaymentBlock = iIndex == (vendor['items'] as List).length - 1;
    String currentUnit = item['selected_unit'];

    final String itemKey = "${vIndex}_$iIndex";
    if (!_shakeKeys.containsKey(itemKey)) {
      _shakeKeys[itemKey] = GlobalKey<ShakeWidgetState>();
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias, // Critical so the bottom green container fits the rounded corners
      child: Column(
        children: [
          // TOP SECTION (Product details, White Background)
          GestureDetector(
            onTap: () {
              final detailItem = Map<String, dynamic>.from(item);
              detailItem['supplier'] = vendor['name'];
              context.push('/product_detail', extra: detailItem);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item['img'] as String, fit: BoxFit.cover),
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
                            child: Text(item['name'] as String, style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 15, height: 1.2)),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(item['price_per_unit'] * item['quantity']).toStringAsFixed(2)}', 
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18, height: 1.1)
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${item['price_per_unit'].toStringAsFixed(2)} ${_getPriceSuffix(currentUnit)}', 
                                style: TextStyle(color: outline, fontSize: 10, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeItem(vIndex, iIndex),
                            behavior: HitTestBehavior.opaque,
                            child: Icon(Icons.delete_outline, color: tertiary, size: 22),
                          ),
                        ],
                      ),
                      if (item['tags'] != null && (item['tags'] as List).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (item['tags'] as List).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag.toString(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Quality tag under the tags
                      Text(
                        item['quality'].toUpperCase(),
                        style: TextStyle(color: _getQualityColor(item['quality']), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 12),
                      
                      // Controls Row (Unit dynamically adapting logic)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Unit Selector (Horizontally scrollable if options are too many)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20)),
                              // Used SingleChildScrollView horizontally so it naturally supports 2, 4 or 10 elements without breaking the layout
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: (item['available_units'] as List<String>).map((unit) {
                                    bool isSelected = currentUnit == unit;
                                    return GestureDetector(
                                      onTap: () => setState(() => item['selected_unit'] = unit),
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(unit, style: TextStyle(color: isSelected ? Colors.white : outline, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ShakeWidget(
                                  key: _shakeKeys[itemKey],
                                  child: Text(
                                    _getLegend(currentUnit),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: secondary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Quantity Selector
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: surfaceContainer,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: outlineVariant.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _updateQuantity(vIndex, iIndex, item['quantity'] - 1, _shakeKeys[itemKey]), 
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: 32,
                                        child: Center(child: Icon(Icons.remove, color: onSurface, size: 16))
                                      )
                                    ),
                                    Container(
                                      width: 36,
                                      alignment: Alignment.center,
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) {
                                            int val = int.tryParse(_qtyControllers["${vIndex}_$iIndex"]!.text) ?? 1;
                                            _updateQuantity(vIndex, iIndex, val, _shakeKeys[itemKey]);
                                          }
                                        },
                                        child: TextField(
                                          controller: _qtyControllers["${vIndex}_$iIndex"],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(color: onSurface, fontWeight: FontWeight.w900, fontSize: 13),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          onChanged: (val) {
                                            if (val.isEmpty) return;
                                            int newQty = int.tryParse(val) ?? 1;
                                            var limits = _getUnitLimits(currentUnit);
                                            
                                            // Immediately limit if user types 0 or goes over the maximum
                                            if (newQty > limits['max']! || newQty == 0) {
                                              _updateQuantity(vIndex, iIndex, newQty, _shakeKeys[itemKey]);
                                            } else {
                                              setState(() {
                                                item['quantity'] = newQty;
                                              });
                                            }
                                          },
                                          onSubmitted: (val) {
                                            int newQty = int.tryParse(val) ?? 1;
                                            _updateQuantity(vIndex, iIndex, newQty, _shakeKeys[itemKey]);
                                          },
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _updateQuantity(vIndex, iIndex, item['quantity'] + 1, _shakeKeys[itemKey]), 
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: 32,
                                        child: Center(child: Icon(Icons.add, color: onSurface, size: 16)),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  )
                )
              ],
            ),
          ),
        ),
          
          // BOTTOM SECTION (Payment and Coupon, Light Green Background)
          if (showPaymentBlock)
            Container(
              color: isDark ? surfaceLow : const Color(0xFFE5F1E9),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Payment Method 
                  GestureDetector(
                    onTap: () => _showPaymentOptions(context, vIndex),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              vendor['payment_method'].toString().contains('Efectivo') ? Icons.payments_outlined : 
                              vendor['payment_method'].toString().contains('Tarjeta') ? Icons.credit_card_outlined : Icons.account_balance_outlined, 
                              color: secondary, size: 20
                            ),
                            const SizedBox(width: 8),
                            Text('Pago: ${vendor['payment_method']}', style: TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text('CAMBIAR', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: outlineVariant.withOpacity(0.3), height: 1),
                  const SizedBox(height: 12),
                  // Coupon Code
                  Row(
                    children: [
                      Icon(Icons.local_offer, color: const Color(0xFF33A15C), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _couponControllers[vIndex],
                          decoration: InputDecoration(
                            hintText: vendor['coupon'] != null ? 'Cupón Activo: ${vendor['coupon']}' : 'Cupón para ${vendor['name']}',
                            hintStyle: TextStyle(
                              color: vendor['coupon'] != null ? const Color(0xFF10B981) : outline.withOpacity(0.8), 
                              fontSize: 13, 
                              fontWeight: vendor['coupon'] != null ? FontWeight.bold : FontWeight.w500
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (vendor['coupon'] != null) ...[
                        GestureDetector(
                          onTap: () => setState(() => vendors[vIndex]['coupon'] = null),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.close, color: outline.withOpacity(0.7), size: 16),
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _couponControllers[vIndex]!,
                        builder: (context, value, child) {
                          final hasText = value.text.isNotEmpty;
                          return GestureDetector(
                            onTap: () {
                              if (hasText) {
                                String code = value.text.trim().toUpperCase();
                                List<String> validCodes = ['VERDE15', 'ORGANICOS', 'PAN2X1'];
                                if (validCodes.contains(code)) {
                                  setState(() {
                                    vendors[vIndex]['coupon'] = code;
                                    _couponControllers[vIndex]!.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cupón aplicado con éxito', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF00462f), duration: Duration(seconds: 2))
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cupón no encontrado', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red, duration: Duration(seconds: 2))
                                  );
                                }
                              } else {
                                _showCouponOptions(context, vIndex);
                              }
                            },
                            behavior: HitTestBehavior.opaque, 
                            child: Text(hasText ? 'VALIDAR' : 'ELEGIR', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
        ],
      )
    );
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  const ShakeWidget({super.key, required this.child});

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _isShaking = false);
        _controller.reset();
      }
    });
  }

  void shake() {
    if (!_isShaking && mounted) {
      setState(() => _isShaking = true);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: _isShaking ? Colors.red : null),
            child: widget.child,
          ),
        );
      },
    );
  }
}
