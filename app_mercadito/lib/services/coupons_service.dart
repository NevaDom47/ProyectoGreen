import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';

class ClaimCouponResult {
  final bool success;
  final String message;
  final Coupon? coupon;

  const ClaimCouponResult({
    required this.success,
    required this.message,
    this.coupon,
  });
}

/// Servicio singleton para la gestión, analítica y reglas de cupones.
class CouponsService {
  CouponsService._() {
    _initSeedCoupons();
    _initSeedBuyerCoupons();
  }

  static final CouponsService instance = CouponsService._();

  final ValueNotifier<List<Coupon>> couponsNotifier = ValueNotifier<List<Coupon>>([]);
  final ValueNotifier<List<Coupon>> activeBuyerCouponsNotifier =
      ValueNotifier<List<Coupon>>([]);
  final ValueNotifier<List<CouponRedemptionHistory>> redemptionHistoryNotifier =
      ValueNotifier<List<CouponRedemptionHistory>>([]);

  List<Coupon> get coupons => couponsNotifier.value;
  List<Coupon> get activeBuyerCoupons => activeBuyerCouponsNotifier.value;
  List<CouponRedemptionHistory> get redemptionHistory => redemptionHistoryNotifier.value;

  void _initSeedCoupons() {
    final now = DateTime.now();
    couponsNotifier.value = [
      Coupon(
        id: 'CPN-001',
        providerId: 'PROV-00000001',
        code: 'COSECHA10',
        title: 'Feria de Cosecha Septiembre',
        category: 'FRUTAS & VERDURAS',
        benefit: const CouponBenefit(
          type: CouponBenefitType.percentage,
          value: 10.0,
        ),
        rule: CouponRule(
          scope: CouponScope.allProducts,
          minPurchase: 1500.0,
          totalUsageLimit: 100,
          usagePerBuyer: 1,
          startDate: DateTime(now.year, 9, 1),
          endDate: DateTime(now.year, 9, 30),
        ),
        target: const CouponTarget(audience: CouponAudience.allBuyers),
        status: CouponStatus.active,
        analytics: const CouponAnalytics(
          publishedCount: 500,
          views: 210,
          saved: 87,
          redeemed: 34,
          salesGenerated: 48500.0,
          discountGiven: 4850.0,
          averageTicket: 1426.0,
          newBuyersAcquired: 12,
        ),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Coupon(
        id: 'CPN-002',
        providerId: 'PROV-00000001',
        code: 'ORGANICOS',
        title: 'Semana Orgánica del Huerto',
        category: 'ORGÁNICOS',
        benefit: const CouponBenefit(
          type: CouponBenefitType.fixedAmount,
          value: 250.0,
        ),
        rule: CouponRule(
          scope: CouponScope.specificCategories,
          targetCategories: ['Orgánicos', 'Vegetales'],
          minPurchase: 2000.0,
          totalUsageLimit: 150,
          usagePerBuyer: 2,
          startDate: DateTime(now.year, 9, 5),
          endDate: DateTime(now.year, 10, 15),
        ),
        target: const CouponTarget(audience: CouponAudience.allBuyers),
        status: CouponStatus.active,
        analytics: const CouponAnalytics(
          publishedCount: 400,
          views: 180,
          saved: 95,
          redeemed: 56,
          salesGenerated: 112000.0,
          discountGiven: 14000.0,
          averageTicket: 2000.0,
          newBuyersAcquired: 18,
        ),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Coupon(
        id: 'CPN-003',
        providerId: 'PROV-00000001',
        code: 'REGRESA15',
        title: 'Recuperación de Clientes',
        category: 'GENERAL',
        benefit: const CouponBenefit(
          type: CouponBenefitType.percentage,
          value: 15.0,
        ),
        rule: CouponRule(
          scope: CouponScope.allProducts,
          minPurchase: 1200.0,
          totalUsageLimit: 50,
          usagePerBuyer: 1,
          startDate: DateTime(now.year, 8, 15),
          endDate: DateTime(now.year, 10, 31),
        ),
        target: const CouponTarget(
          audience: CouponAudience.inactiveBuyers,
          inactiveDaysThreshold: 60,
        ),
        status: CouponStatus.active,
        analytics: const CouponAnalytics(
          publishedCount: 120,
          views: 64,
          saved: 32,
          redeemed: 19,
          salesGenerated: 28500.0,
          discountGiven: 4275.0,
          averageTicket: 1500.0,
          newBuyersAcquired: 0,
        ),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Coupon(
        id: 'CPN-004',
        providerId: 'PROV-00000001',
        code: 'PAN2X1',
        title: '2x1 Panadería Artesanal',
        category: 'PANADERÍA',
        benefit: const CouponBenefit(
          type: CouponBenefitType.twoForOne,
          value: 0.0,
        ),
        rule: CouponRule(
          scope: CouponScope.specificCategories,
          targetCategories: ['Panadería'],
          minPurchase: 500.0,
          totalUsageLimit: 60,
          usagePerBuyer: 1,
          startDate: DateTime(now.year, 8, 1),
          endDate: DateTime(now.year, 9, 20),
        ),
        target: const CouponTarget(audience: CouponAudience.frequentBuyers),
        status: CouponStatus.paused,
        analytics: const CouponAnalytics(
          publishedCount: 200,
          views: 110,
          saved: 45,
          redeemed: 28,
          salesGenerated: 22400.0,
          discountGiven: 5600.0,
          averageTicket: 800.0,
          newBuyersAcquired: 7,
        ),
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Coupon(
        id: 'CPN-005',
        providerId: 'PROV-00000001',
        code: 'VERDE15',
        title: 'Bienvenida Nuevos Compradores',
        category: 'FRUTAS & VERDURAS',
        benefit: const CouponBenefit(
          type: CouponBenefitType.percentage,
          value: 15.0,
        ),
        rule: CouponRule(
          scope: CouponScope.allProducts,
          minPurchase: 3000.0,
          totalUsageLimit: 40,
          usagePerBuyer: 1,
          startDate: DateTime(now.year, 9, 1),
          endDate: DateTime(now.year, 10, 30),
        ),
        target: const CouponTarget(audience: CouponAudience.newBuyers),
        status: CouponStatus.active,
        analytics: const CouponAnalytics(
          publishedCount: 80,
          views: 42,
          saved: 20,
          redeemed: 6,
          salesGenerated: 18000.0,
          discountGiven: 2700.0,
          averageTicket: 3000.0,
          newBuyersAcquired: 6,
        ),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  // --- CRUD Operations ---

  void createCoupon(Coupon coupon) {
    final current = List<Coupon>.from(couponsNotifier.value);
    // Nuevos cupones inician obligatoriamente en PAUSA y con hasBeenActivated = false
    final initialPaused = coupon.copyWith(
      status: CouponStatus.paused,
      hasBeenActivated: false,
    );
    current.insert(0, initialPaused);
    couponsNotifier.value = current;
  }

  void updateCoupon(Coupon updated) {
    final current = List<Coupon>.from(couponsNotifier.value);
    final idx = current.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      // Solo se permite actualizar si el cupón está pausado y nunca se ha activado
      final existing = current[idx];
      if (existing.canBeEdited) {
        current[idx] = updated;
        couponsNotifier.value = current;
      }
    }
  }

  void togglePauseCoupon(String couponId) {
    final current = List<Coupon>.from(couponsNotifier.value);
    final idx = current.indexWhere((c) => c.id == couponId);
    if (idx != -1) {
      final coupon = current[idx];
      if (coupon.status == CouponStatus.active) {
        current[idx] = coupon.copyWith(status: CouponStatus.paused);
      } else {
        // Al colocar en activo por primera vez, se marca permanentemente hasBeenActivated = true
        current[idx] = coupon.copyWith(
          status: CouponStatus.active,
          hasBeenActivated: true,
        );
      }
      couponsNotifier.value = current;
    }
  }

  void finalizeCoupon(String couponId) {
    final current = List<Coupon>.from(couponsNotifier.value);
    final idx = current.indexWhere((c) => c.id == couponId);
    if (idx != -1) {
      current[idx] = current[idx].copyWith(status: CouponStatus.expired);
      couponsNotifier.value = current;
    }
  }

  void duplicateCoupon(String couponId) {
    final current = List<Coupon>.from(couponsNotifier.value);
    final match = current.firstWhere((c) => c.id == couponId, orElse: () => current.first);
    final newCode = generateCouponCode(prefix: match.code.substring(0, min(5, match.code.length)));
    final newCoupon = match.copyWith(
      id: 'CPN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      code: newCode,
      title: '${match.title} (Copia)',
      status: CouponStatus.paused, // La copia también nace en pausa
      hasBeenActivated: false,
      analytics: const CouponAnalytics(),
      createdAt: DateTime.now(),
    );
    current.insert(0, newCoupon);
    couponsNotifier.value = current;
  }

  void deleteCoupon(String couponId) {
    final current = List<Coupon>.from(couponsNotifier.value);
    current.removeWhere((c) => c.id == couponId);
    couponsNotifier.value = current;
  }

  // --- Helpers ---

  String generateCouponCode({String? prefix}) {
    final basePrefix = (prefix != null && prefix.trim().isNotEmpty)
        ? prefix.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')
        : 'COSECHA';
    final randomSuffix = Random().nextInt(900) + 100;
    return '$basePrefix$randomSuffix';
  }

  Map<String, dynamic> getGlobalMetrics() {
    final list = couponsNotifier.value;
    final activeCount = list.where((c) => c.status == CouponStatus.active).length;
    final usedCount = list.fold<int>(0, (sum, c) => sum + c.analytics.redeemed);
    final redemptionsMonth = 37; // Muestra representativa mensual
    final totalDiscount = list.fold<double>(0.0, (sum, c) => sum + c.analytics.discountGiven);
    final totalSales = list.fold<double>(0.0, (sum, c) => sum + c.analytics.salesGenerated);

    return {
      'activeCount': activeCount,
      'usedCount': usedCount,
      'redemptionsThisMonth': redemptionsMonth,
      'totalDiscount': totalDiscount,
      'totalSales': totalSales,
    };
  }

  void _initSeedBuyerCoupons() {
    final now = DateTime.now();
    activeBuyerCouponsNotifier.value = [
      couponsNotifier.value.firstWhere(
        (c) => c.code == 'VERDE15',
        orElse: () => couponsNotifier.value.first,
      ),
      couponsNotifier.value.firstWhere(
        (c) => c.code == 'ORGANICOS',
        orElse: () => couponsNotifier.value[1],
      ),
      couponsNotifier.value.firstWhere(
        (c) => c.code == 'COSECHA10',
        orElse: () => couponsNotifier.value.first,
      ),
    ];

    redemptionHistoryNotifier.value = [
      CouponRedemptionHistory(
        id: 'HIST-001',
        couponCode: 'COSECHA10',
        couponTitle: 'Feria de Cosecha Septiembre',
        category: 'FRUTAS & VERDURAS',
        discountApplied: '10% OFF',
        savingsAmount: 250.0,
        usedAt: now.subtract(const Duration(days: 2, hours: 4)),
        orderId: '#FAC-2026-0089',
        providerName: 'Finca Orgánica Monteverde',
        products: const [
          'Manzanas Gala (3 lb)',
          'Tomates de Ensalada (2 lb)',
          'Lechuga Romana (1 un)',
        ],
        productDetails: const [
          RedeemedProductItem(
            sku: 'FRU-MAN-01',
            name: 'Manzanas Gala (3 lb)',
            isWholesale: false, // Al detalle
          ),
          RedeemedProductItem(
            sku: 'HOR-TOM-02',
            name: 'Tomates de Ensalada (2 lb)',
            isWholesale: true, // Al por mayor
          ),
          RedeemedProductItem(
            sku: 'HOR-LEC-03',
            name: 'Lechuga Romana (1 un)',
            isWholesale: false, // Al detalle
          ),
        ],
        isExpired: false,
      ),
      CouponRedemptionHistory(
        id: 'HIST-002',
        couponCode: 'PAN2X1',
        couponTitle: '2x1 Panadería Artesanal',
        category: 'PANADERÍA',
        discountApplied: 'Promoción 2x1',
        savingsAmount: 320.0,
        usedAt: now.subtract(const Duration(days: 8, hours: 2)),
        orderId: '#FAC-2026-0072',
        providerName: 'Panadería Tradicional El Trigo',
        products: const [
          'Baguette Rústica (2 un)',
          'Pan Campesino de Masa Madre (1 un)',
        ],
        productDetails: const [
          RedeemedProductItem(
            sku: 'PAN-BAG-01',
            name: 'Baguette Rústica (2 un)',
            isWholesale: false,
          ),
          RedeemedProductItem(
            sku: 'PAN-CMP-02',
            name: 'Pan Campesino de Masa Madre (1 un)',
            isWholesale: false,
          ),
        ],
        isExpired: false,
      ),
      CouponRedemptionHistory(
        id: 'HIST-003',
        couponCode: 'VERDE15',
        couponTitle: 'Bienvenida Nuevos Compradores',
        category: 'FRUTAS & VERDURAS',
        discountApplied: '15% OFF',
        savingsAmount: 480.0,
        usedAt: now.subtract(const Duration(days: 23, hours: 5)),
        orderId: '#FAC-2026-0051',
        providerName: 'Huerto Los Pinos',
        products: const [
          'Aguacates Hass (4 un)',
          'Plátanos Verdes (1 racimo)',
          'Mandarinas Criollas (3 lb)',
        ],
        productDetails: const [
          RedeemedProductItem(
            sku: 'FRU-AGU-01',
            name: 'Aguacates Hass (4 un)',
            isWholesale: false,
          ),
          RedeemedProductItem(
            sku: 'TUB-PLA-02',
            name: 'Plátanos Verdes (1 racimo)',
            isWholesale: true,
          ),
          RedeemedProductItem(
            sku: 'CIT-MAN-03',
            name: 'Mandarinas Criollas (3 lb)',
            isWholesale: false,
          ),
        ],
        isExpired: false,
      ),
      CouponRedemptionHistory(
        id: 'HIST-004',
        couponCode: 'PROMO-VENCIDA',
        couponTitle: 'Especial Fin de Semana',
        category: 'LÁCTEOS',
        discountApplied: 'RD\$ 150 DTO',
        savingsAmount: 0.0,
        usedAt: now.subtract(const Duration(days: 35)),
        orderId: 'Sin orden asociada',
        providerName: 'Quesería La Pradera',
        products: const [
          'Cupón expiró sin ser utilizado en una compra',
        ],
        productDetails: const [
          RedeemedProductItem(
            sku: 'SIN-SKU',
            name: 'Cupón expiró sin ser utilizado en una compra',
            isWholesale: false,
          ),
        ],
        isExpired: true,
      ),
    ];
  }

  /// Catálogo de productos del proveedor con duplicación para Al Detalle y Al Por Mayor
  List<Map<String, dynamic>> getProviderProductsForCoupons() => [
        {
          'id': 'PROD-101-DET',
          'sku': 'HOR-TOM-01',
          'name': 'Tomate Saladette',
          'modality': 'Al detalle',
          'isWholesale': false,
          'priceFormatted': 'RD\$ 28.50 / LB',
        },
        {
          'id': 'PROD-101-MAY',
          'sku': 'HOR-TOM-01',
          'name': 'Tomate Saladette',
          'modality': 'Al por mayor',
          'isWholesale': true,
          'priceFormatted': 'RD\$ 22.00 / Caja 25 LB',
        },
        {
          'id': 'PROD-102-DET',
          'sku': 'FRU-AGU-02',
          'name': 'Aguacate Hass',
          'modality': 'Al detalle',
          'isWholesale': false,
          'priceFormatted': 'RD\$ 65.00 / Ud',
        },
        {
          'id': 'PROD-102-MAY',
          'sku': 'FRU-AGU-02',
          'name': 'Aguacate Hass',
          'modality': 'Al por mayor',
          'isWholesale': true,
          'priceFormatted': 'RD\$ 45.00 / Huacal 30 Ud',
        },
        {
          'id': 'PROD-103-DET',
          'sku': 'HOR-CEB-03',
          'name': 'Cebolla Roja Criolla',
          'modality': 'Al detalle',
          'isWholesale': false,
          'priceFormatted': 'RD\$ 40.00 / LB',
        },
        {
          'id': 'PROD-103-MAY',
          'sku': 'HOR-CEB-03',
          'name': 'Cebolla Roja Criolla',
          'modality': 'Al por mayor',
          'isWholesale': true,
          'priceFormatted': 'RD\$ 32.00 / Saco 50 LB',
        },
        {
          'id': 'PROD-104-DET',
          'sku': 'TUB-PLA-04',
          'name': 'Plátano Barahonero',
          'modality': 'Al detalle',
          'isWholesale': false,
          'priceFormatted': 'RD\$ 18.00 / Ud',
        },
        {
          'id': 'PROD-104-MAY',
          'sku': 'TUB-PLA-04',
          'name': 'Plátano Barahonero',
          'modality': 'Al por mayor',
          'isWholesale': true,
          'priceFormatted': 'RD\$ 13.50 / Cien (100 Ud)',
        },
        {
          'id': 'PROD-105-DET',
          'sku': 'FRU-MAN-05',
          'name': 'Mango Banilejo',
          'modality': 'Al detalle',
          'isWholesale': false,
          'priceFormatted': 'RD\$ 35.00 / Ud',
        },
        {
          'id': 'PROD-105-MAY',
          'sku': 'FRU-MAN-05',
          'name': 'Mango Banilejo',
          'modality': 'Al por mayor',
          'isWholesale': true,
          'priceFormatted': 'RD\$ 25.00 / Caja 20 Ud',
        },
      ];

  /// Listado de compradores que han cerrado negociaciones con el proveedor
  List<Map<String, dynamic>> getProviderClosedNegotiationBuyers() => [
        {
          'id': 'BUY-001',
          'name': 'Rafael Marte',
          'business': 'Colmado San Rafael',
          'owner': 'Rafael Marte',
          'closedNegotiations': 8,
          'lastNegotiationDaysAgo': 4,
        },
        {
          'id': 'BUY-002',
          'name': 'Carmen Jiménez',
          'business': 'Supermercado La Fe',
          'owner': 'Carmen Jiménez',
          'closedNegotiations': 15,
          'lastNegotiationDaysAgo': 2,
        },
        {
          'id': 'BUY-003',
          'name': 'Chef Andrés Peña',
          'business': 'Restaurante El Criollo',
          'owner': 'Chef Andrés Peña',
          'closedNegotiations': 6,
          'lastNegotiationDaysAgo': 18,
        },
        {
          'id': 'BUY-004',
          'name': 'Pedro Díaz',
          'business': 'Frutería Hermanos Díaz',
          'owner': 'Pedro Díaz',
          'closedNegotiations': 4,
          'lastNegotiationDaysAgo': 22,
        },
        {
          'id': 'BUY-005',
          'name': 'Lucía Rosario',
          'business': 'Minimarket Esperanza',
          'owner': 'Lucía Rosario',
          'closedNegotiations': 1,
          'lastNegotiationDaysAgo': 5,
        },
        {
          'id': 'BUY-006',
          'name': 'Gourmet Kitchen',
          'business': 'Hotel Boutique Colonial',
          'owner': 'Gourmet Kitchen',
          'closedNegotiations': 3,
          'lastNegotiationDaysAgo': 35,
        },
      ];

  ClaimCouponResult claimCouponCode(String rawCode) {
    final cleanCode = rawCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return const ClaimCouponResult(
        success: false,
        message: 'Por favor, ingresa un código de cupón.',
      );
    }

    final alreadyClaimed = activeBuyerCouponsNotifier.value.any(
      (c) => c.code.toUpperCase() == cleanCode,
    );
    if (alreadyClaimed) {
      return ClaimCouponResult(
        success: false,
        message: 'Ya tienes el cupón $cleanCode en tus cupones activos.',
      );
    }

    final allCoupons = couponsNotifier.value;
    Coupon? matchingCoupon;
    for (final c in allCoupons) {
      if (c.code.toUpperCase() == cleanCode) {
        matchingCoupon = c;
        break;
      }
    }

    if (matchingCoupon != null) {
      if (matchingCoupon.status != CouponStatus.active) {
        return ClaimCouponResult(
          success: false,
          message:
              'El cupón $cleanCode está ${matchingCoupon.status.label.toLowerCase()} y no se puede canjear.',
        );
      }

      final currentBuyerCoupons =
          List<Coupon>.from(activeBuyerCouponsNotifier.value);
      currentBuyerCoupons.insert(0, matchingCoupon);
      activeBuyerCouponsNotifier.value = currentBuyerCoupons;

      final currentCoupons = List<Coupon>.from(couponsNotifier.value);
      final idx = currentCoupons.indexWhere((c) => c.id == matchingCoupon!.id);
      if (idx != -1) {
        final currentItem = currentCoupons[idx];
        currentCoupons[idx] = currentItem.copyWith(
          analytics: currentItem.analytics.copyWith(
            saved: currentItem.analytics.saved + 1,
          ),
        );
        couponsNotifier.value = currentCoupons;
      }

      return ClaimCouponResult(
        success: true,
        message:
            '¡Cupón $cleanCode canjeado con éxito! Obtienes ${matchingCoupon.benefit.displayTitle}.',
        coupon: matchingCoupon,
      );
    }

    if (cleanCode == 'REGRESA15' ||
        cleanCode == 'BIENVENIDO' ||
        cleanCode == 'MERCADITO10') {
      final now = DateTime.now();
      final specialCoupon = Coupon(
        id: 'CPN-SPECIAL-${now.millisecondsSinceEpoch}',
        providerId: 'PROV-00000001',
        code: cleanCode,
        title: cleanCode == 'REGRESA15'
            ? 'Cupón de Reactivación'
            : 'Cupón de Promoción Especial',
        category: 'GENERAL',
        benefit: const CouponBenefit(
          type: CouponBenefitType.percentage,
          value: 15.0,
        ),
        rule: CouponRule(
          scope: CouponScope.allProducts,
          minPurchase: 1000.0,
          totalUsageLimit: 100,
          usagePerBuyer: 1,
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
        ),
        target: const CouponTarget(audience: CouponAudience.allBuyers),
        status: CouponStatus.active,
        analytics: const CouponAnalytics(
          publishedCount: 100,
          views: 1,
          saved: 1,
          redeemed: 0,
        ),
        createdAt: now,
      );

      final currentBuyerCoupons =
          List<Coupon>.from(activeBuyerCouponsNotifier.value);
      currentBuyerCoupons.insert(0, specialCoupon);
      activeBuyerCouponsNotifier.value = currentBuyerCoupons;

      return ClaimCouponResult(
        success: true,
        message:
            '¡Cupón $cleanCode canjeado con éxito! Obtienes ${specialCoupon.benefit.displayTitle}.',
        coupon: specialCoupon,
      );
    }

    return ClaimCouponResult(
      success: false,
      message: 'El código de cupón "$cleanCode" no es válido o ha expirado.',
    );
  }
}
