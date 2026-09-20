import 'package:flutter/foundation.dart';

/// Tipo de beneficio que ofrece el cupón.
enum CouponBenefitType {
  percentage,
  fixedAmount,
  freeShipping,
  twoForOne,
  giftProduct,
  specialPrice,
}

extension CouponBenefitTypeExt on CouponBenefitType {
  String get label {
    switch (this) {
      case CouponBenefitType.percentage:
        return 'Porcentaje (%)';
      case CouponBenefitType.fixedAmount:
        return 'Monto Fijo (RD\$)';
      case CouponBenefitType.freeShipping:
        return 'Envío Gratis';
      case CouponBenefitType.twoForOne:
        return 'Promoción 2x1';
      case CouponBenefitType.giftProduct:
        return 'Producto / Regalo';
      case CouponBenefitType.specialPrice:
        return 'Precio Especial';
    }
  }

  String get shortTag {
    switch (this) {
      case CouponBenefitType.percentage:
        return 'PORCENTAJE';
      case CouponBenefitType.fixedAmount:
        return 'DESCUENTO';
      case CouponBenefitType.freeShipping:
        return 'ENVÍO GRATIS';
      case CouponBenefitType.twoForOne:
        return '2x1';
      case CouponBenefitType.giftProduct:
        return 'REGALO';
      case CouponBenefitType.specialPrice:
        return 'PRECIO ESPECIAL';
    }
  }
}

/// Detalle del beneficio que percibe el comprador.
@immutable
class CouponBenefit {
  final CouponBenefitType type;
  final double value; // 10 para 10%, 250 para RD$250
  final String? customGiftName;
  final String? specialPriceLabel;

  const CouponBenefit({
    required this.type,
    this.value = 0.0,
    this.customGiftName,
    this.specialPriceLabel,
  });

  String get displayTitle {
    switch (type) {
      case CouponBenefitType.percentage:
        return '${value.toStringAsFixed(0)}% OFF';
      case CouponBenefitType.fixedAmount:
        return 'RD\$ ${value.toStringAsFixed(0)} DTO';
      case CouponBenefitType.freeShipping:
        return 'ENVÍO GRATIS';
      case CouponBenefitType.twoForOne:
        return '2x1';
      case CouponBenefitType.giftProduct:
        return customGiftName != null && customGiftName!.isNotEmpty
            ? 'Regalo: $customGiftName'
            : 'Producto Regalo';
      case CouponBenefitType.specialPrice:
        return specialPriceLabel ?? 'Precio Especial';
    }
  }

  CouponBenefit copyWith({
    CouponBenefitType? type,
    double? value,
    String? customGiftName,
    String? specialPriceLabel,
  }) {
    return CouponBenefit(
      type: type ?? this.type,
      value: value ?? this.value,
      customGiftName: customGiftName ?? this.customGiftName,
      specialPriceLabel: specialPriceLabel ?? this.specialPriceLabel,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'value': value,
        'customGiftName': customGiftName,
        'specialPriceLabel': specialPriceLabel,
      };

  factory CouponBenefit.fromJson(Map<String, dynamic> json) {
    return CouponBenefit(
      type: CouponBenefitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CouponBenefitType.percentage,
      ),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      customGiftName: json['customGiftName'] as String?,
      specialPriceLabel: json['specialPriceLabel'] as String?,
    );
  }
}

/// Alcance o aplicación de los productos.
enum CouponScope {
  allProducts,
  specificProducts,
  specificCategories,
}

extension CouponScopeExt on CouponScope {
  String get label {
    switch (this) {
      case CouponScope.allProducts:
        return 'Todos mis productos';
      case CouponScope.specificProducts:
        return 'Productos específicos';
      case CouponScope.specificCategories:
        return 'Categorías específicas';
    }
  }
}

/// Reglas de uso y validación del cupón.
@immutable
class CouponRule {
  final CouponScope scope;
  final List<String> targetProducts;
  final List<String> targetCategories;
  final double minPurchase; // e.g. 1500.0 RD$
  final int totalUsageLimit; // e.g. 100
  final int usagePerBuyer; // e.g. 1
  final DateTime startDate;
  final DateTime endDate;
  final List<int> applicableDays; // 1 = Lunes, 7 = Domingo (vacío = todos)

  const CouponRule({
    this.scope = CouponScope.allProducts,
    this.targetProducts = const [],
    this.targetCategories = const [],
    this.minPurchase = 0.0,
    this.totalUsageLimit = 100,
    this.usagePerBuyer = 1,
    required this.startDate,
    required this.endDate,
    this.applicableDays = const [],
  });

  String get conditionSummary {
    final List<String> parts = [];
    if (minPurchase > 0) {
      parts.add('Compra mínima RD\$ ${minPurchase.toStringAsFixed(0)}');
    } else {
      parts.add('Sin monto mínimo');
    }
    if (scope == CouponScope.allProducts) {
      parts.add('En todos los productos');
    } else if (scope == CouponScope.specificCategories) {
      parts.add('Cat: ${targetCategories.join(", ")}');
    } else if (scope == CouponScope.specificProducts) {
      parts.add('${targetProducts.length} productos seleccionados');
    }
    return parts.join(' • ');
  }

  CouponRule copyWith({
    CouponScope? scope,
    List<String>? targetProducts,
    List<String>? targetCategories,
    double? minPurchase,
    int? totalUsageLimit,
    int? usagePerBuyer,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? applicableDays,
  }) {
    return CouponRule(
      scope: scope ?? this.scope,
      targetProducts: targetProducts ?? this.targetProducts,
      targetCategories: targetCategories ?? this.targetCategories,
      minPurchase: minPurchase ?? this.minPurchase,
      totalUsageLimit: totalUsageLimit ?? this.totalUsageLimit,
      usagePerBuyer: usagePerBuyer ?? this.usagePerBuyer,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicableDays: applicableDays ?? this.applicableDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'scope': scope.name,
        'targetProducts': targetProducts,
        'targetCategories': targetCategories,
        'minPurchase': minPurchase,
        'totalUsageLimit': totalUsageLimit,
        'usagePerBuyer': usagePerBuyer,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'applicableDays': applicableDays,
      };

  factory CouponRule.fromJson(Map<String, dynamic> json) {
    return CouponRule(
      scope: CouponScope.values.firstWhere(
        (e) => e.name == json['scope'],
        orElse: () => CouponScope.allProducts,
      ),
      targetProducts: List<String>.from(json['targetProducts'] ?? []),
      targetCategories: List<String>.from(json['targetCategories'] ?? []),
      minPurchase: (json['minPurchase'] as num?)?.toDouble() ?? 0.0,
      totalUsageLimit: json['totalUsageLimit'] as int? ?? 100,
      usagePerBuyer: json['usagePerBuyer'] as int? ?? 1,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      applicableDays: List<int>.from(json['applicableDays'] ?? []),
    );
  }
}

/// Segmentación y audiencia objetivo del cupón.
enum CouponAudience {
  allBuyers,
  newBuyers,
  frequentBuyers,
  inactiveBuyers, // Clientes que no compran hace X días (e.g. REGRESA15)
  selectedBuyers,
}

extension CouponAudienceExt on CouponAudience {
  String get label {
    switch (this) {
      case CouponAudience.allBuyers:
        return 'Todos los compradores';
      case CouponAudience.newBuyers:
        return 'Nuevos compradores';
      case CouponAudience.frequentBuyers:
        return 'Compradores frecuentes';
      case CouponAudience.inactiveBuyers:
        return 'Recuperación de clientes inactivos';
      case CouponAudience.selectedBuyers:
        return 'Compradores seleccionados';
    }
  }
}

@immutable
class CouponTarget {
  final CouponAudience audience;
  final int inactiveDaysThreshold; // e.g. 60 días
  final List<String> selectedBuyerIds;

  const CouponTarget({
    this.audience = CouponAudience.allBuyers,
    this.inactiveDaysThreshold = 60,
    this.selectedBuyerIds = const [],
  });

  String get audienceLabel {
    if (audience == CouponAudience.inactiveBuyers) {
      return 'Inactivos > $inactiveDaysThreshold días';
    }
    if (audience == CouponAudience.selectedBuyers) {
      return '${selectedBuyerIds.length} compradores VIP';
    }
    return audience.label;
  }

  CouponTarget copyWith({
    CouponAudience? audience,
    int? inactiveDaysThreshold,
    List<String>? selectedBuyerIds,
  }) {
    return CouponTarget(
      audience: audience ?? this.audience,
      inactiveDaysThreshold: inactiveDaysThreshold ?? this.inactiveDaysThreshold,
      selectedBuyerIds: selectedBuyerIds ?? this.selectedBuyerIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'audience': audience.name,
        'inactiveDaysThreshold': inactiveDaysThreshold,
        'selectedBuyerIds': selectedBuyerIds,
      };

  factory CouponTarget.fromJson(Map<String, dynamic> json) {
    return CouponTarget(
      audience: CouponAudience.values.firstWhere(
        (e) => e.name == json['audience'],
        orElse: () => CouponAudience.allBuyers,
      ),
      inactiveDaysThreshold: json['inactiveDaysThreshold'] as int? ?? 60,
      selectedBuyerIds: List<String>.from(json['selectedBuyerIds'] ?? []),
    );
  }
}

/// Estado actual del cupón.
enum CouponStatus {
  active,
  paused,
  expired,
  depleted,
}

extension CouponStatusExt on CouponStatus {
  String get label {
    switch (this) {
      case CouponStatus.active:
        return 'Activo';
      case CouponStatus.paused:
        return 'Pausado';
      case CouponStatus.expired:
        return 'Expirado';
      case CouponStatus.depleted:
        return 'Agotado';
    }
  }
}

/// Métricas de rendimiento y embudo de conversión del cupón.
@immutable
class CouponAnalytics {
  final int publishedCount; // Personas a las que se les publicó (e.g. 500)
  final int views; // Personas que lo vieron (e.g. 210)
  final int saved; // Personas que lo guardaron (e.g. 87)
  final int redeemed; // Personas que lo utilizaron (e.g. 34)
  final double salesGenerated; // RD$ 48,500
  final double discountGiven; // RD$ 4,850
  final double averageTicket; // RD$ 1,426
  final int newBuyersAcquired; // 12

  const CouponAnalytics({
    this.publishedCount = 0,
    this.views = 0,
    this.saved = 0,
    this.redeemed = 0,
    this.salesGenerated = 0.0,
    this.discountGiven = 0.0,
    this.averageTicket = 0.0,
    this.newBuyersAcquired = 0,
  });

  double get utilizationRate {
    if (views == 0) return 0.0;
    return (redeemed / views) * 100;
  }

  CouponAnalytics copyWith({
    int? publishedCount,
    int? views,
    int? saved,
    int? redeemed,
    double? salesGenerated,
    double? discountGiven,
    double? averageTicket,
    int? newBuyersAcquired,
  }) {
    return CouponAnalytics(
      publishedCount: publishedCount ?? this.publishedCount,
      views: views ?? this.views,
      saved: saved ?? this.saved,
      redeemed: redeemed ?? this.redeemed,
      salesGenerated: salesGenerated ?? this.salesGenerated,
      discountGiven: discountGiven ?? this.discountGiven,
      averageTicket: averageTicket ?? this.averageTicket,
      newBuyersAcquired: newBuyersAcquired ?? this.newBuyersAcquired,
    );
  }

  Map<String, dynamic> toJson() => {
        'publishedCount': publishedCount,
        'views': views,
        'saved': saved,
        'redeemed': redeemed,
        'salesGenerated': salesGenerated,
        'discountGiven': discountGiven,
        'averageTicket': averageTicket,
        'newBuyersAcquired': newBuyersAcquired,
      };

  factory CouponAnalytics.fromJson(Map<String, dynamic> json) {
    return CouponAnalytics(
      publishedCount: json['publishedCount'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      saved: json['saved'] as int? ?? 0,
      redeemed: json['redeemed'] as int? ?? 0,
      salesGenerated: (json['salesGenerated'] as num?)?.toDouble() ?? 0.0,
      discountGiven: (json['discountGiven'] as num?)?.toDouble() ?? 0.0,
      averageTicket: (json['averageTicket'] as num?)?.toDouble() ?? 0.0,
      newBuyersAcquired: json['newBuyersAcquired'] as int? ?? 0,
    );
  }
}

/// Entidad central del Cupón.
@immutable
class Coupon {
  final String id;
  final String providerId;
  final String code; // e.g. COSECHA10
  final String title; // e.g. "Feria de Septiembre"
  final String category; // e.g. "FRUTAS & VERDURAS", "ORGÁNICOS", "PANADERÍA"
  final int? iconCodePoint;
  final CouponBenefit benefit;
  final CouponRule rule;
  final CouponTarget target;
  final CouponStatus status;
  final CouponAnalytics analytics;
  final DateTime createdAt;
  final bool hasBeenActivated; // True si alguna vez se activó (bloquea ediciones futuras)

  const Coupon({
    required this.id,
    required this.providerId,
    required this.code,
    required this.title,
    this.category = 'GENERAL',
    this.iconCodePoint,
    required this.benefit,
    required this.rule,
    this.target = const CouponTarget(),
    this.status = CouponStatus.active,
    this.analytics = const CouponAnalytics(),
    required this.createdAt,
    this.hasBeenActivated = false,
  });

  bool get isActive => status == CouponStatus.active && DateTime.now().isBefore(rule.endDate);

  /// Solo se puede editar si está pausado y nunca ha sido activado
  bool get canBeEdited => status == CouponStatus.paused && !hasBeenActivated;

  String get dateRangeFormatted {
    final start = '${rule.startDate.day.toString().padLeft(2, '0')}/${rule.startDate.month.toString().padLeft(2, '0')}/${rule.startDate.year.toString().substring(2)}';
    final end = '${rule.endDate.day.toString().padLeft(2, '0')}/${rule.endDate.month.toString().padLeft(2, '0')}/${rule.endDate.year.toString().substring(2)}';
    return '$start - $end';
  }

  Coupon copyWith({
    String? id,
    String? providerId,
    String? code,
    String? title,
    String? category,
    int? iconCodePoint,
    CouponBenefit? benefit,
    CouponRule? rule,
    CouponTarget? target,
    CouponStatus? status,
    CouponAnalytics? analytics,
    DateTime? createdAt,
    bool? hasBeenActivated,
  }) {
    return Coupon(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      code: code ?? this.code,
      title: title ?? this.title,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      benefit: benefit ?? this.benefit,
      rule: rule ?? this.rule,
      target: target ?? this.target,
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      createdAt: createdAt ?? this.createdAt,
      hasBeenActivated: hasBeenActivated ?? this.hasBeenActivated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'code': code,
        'title': title,
        'category': category,
        'iconCodePoint': iconCodePoint,
        'benefit': benefit.toJson(),
        'rule': rule.toJson(),
        'target': target.toJson(),
        'status': status.name,
        'analytics': analytics.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'hasBeenActivated': hasBeenActivated,
      };

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      providerId: json['providerId'] as String? ?? 'PROV-00000001',
      code: json['code'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'GENERAL',
      iconCodePoint: json['iconCodePoint'] as int?,
      benefit: CouponBenefit.fromJson(json['benefit'] as Map<String, dynamic>),
      rule: CouponRule.fromJson(json['rule'] as Map<String, dynamic>),
      target: json['target'] != null
          ? CouponTarget.fromJson(json['target'] as Map<String, dynamic>)
          : const CouponTarget(),
      status: CouponStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CouponStatus.active,
      ),
      analytics: json['analytics'] != null
          ? CouponAnalytics.fromJson(json['analytics'] as Map<String, dynamic>)
          : const CouponAnalytics(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      hasBeenActivated: json['hasBeenActivated'] as bool? ?? false,
    );
  }
}

/// Detalle de producto en compra con código único y modalidad de venta.
@immutable
class RedeemedProductItem {
  final String sku; // Código único del producto (ej. HOR-TOM-01)
  final String name; // Nombre del producto (ej. Tomates de Ensalada (2 lb))
  final bool isWholesale; // false = Al detalle, true = Al por mayor

  const RedeemedProductItem({
    required this.sku,
    required this.name,
    this.isWholesale = false,
  });

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'isWholesale': isWholesale,
      };

  factory RedeemedProductItem.fromJson(Map<String, dynamic> json) =>
      RedeemedProductItem(
        sku: json['sku'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isWholesale: json['isWholesale'] as bool? ?? false,
      );
}

/// Registro del historial de uso o vencimiento de un cupón por un comprador.
@immutable
class CouponRedemptionHistory {
  final String id;
  final String couponCode;
  final String couponTitle;
  final String category;
  final String discountApplied;
  final double savingsAmount;
  final DateTime usedAt;
  final String orderId;
  final String providerName;
  final List<String> products;
  final List<RedeemedProductItem> productDetails;
  final bool isExpired;

  const CouponRedemptionHistory({
    required this.id,
    required this.couponCode,
    required this.couponTitle,
    required this.category,
    required this.discountApplied,
    required this.savingsAmount,
    required this.usedAt,
    required this.orderId,
    required this.providerName,
    required this.products,
    this.productDetails = const [],
    this.isExpired = false,
  });

  String get formattedDate {
    final day = usedAt.day.toString().padLeft(2, '0');
    final month = usedAt.month.toString().padLeft(2, '0');
    final year = usedAt.year;
    final hour = usedAt.hour.toString().padLeft(2, '0');
    final minute = usedAt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'couponCode': couponCode,
        'couponTitle': couponTitle,
        'category': category,
        'discountApplied': discountApplied,
        'savingsAmount': savingsAmount,
        'usedAt': usedAt.toIso8601String(),
        'orderId': orderId,
        'providerName': providerName,
        'products': products,
        'productDetails': productDetails.map((p) => p.toJson()).toList(),
        'isExpired': isExpired,
      };

  factory CouponRedemptionHistory.fromJson(Map<String, dynamic> json) =>
      CouponRedemptionHistory(
        id: json['id'] as String,
        couponCode: json['couponCode'] as String,
        couponTitle: json['couponTitle'] as String,
        category: json['category'] as String,
        discountApplied: json['discountApplied'] as String,
        savingsAmount: (json['savingsAmount'] as num).toDouble(),
        usedAt: DateTime.parse(json['usedAt'] as String),
        orderId: json['orderId'] as String,
        providerName: json['providerName'] as String,
        products:
            (json['products'] as List<dynamic>).map((e) => e as String).toList(),
        productDetails: json['productDetails'] != null
            ? (json['productDetails'] as List<dynamic>)
                .map((e) => RedeemedProductItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
        isExpired: json['isExpired'] as bool? ?? false,
      );
}
