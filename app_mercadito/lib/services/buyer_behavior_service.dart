import 'dart:math';

/// Representa un evento individual de compra realizado por un comprador
class BuyerPurchaseEvent {
  final String orderId;
  final String buyerId;
  final String productName;
  final String category;
  final double quantityKg;
  final bool isWholesale;
  final String paymentMethod;
  final DateTime purchaseDate;
  final double amount;

  const BuyerPurchaseEvent({
    required this.orderId,
    required this.buyerId,
    required this.productName,
    required this.category,
    required this.quantityKg,
    required this.isWholesale,
    required this.paymentMethod,
    required this.purchaseDate,
    required this.amount,
  });
}

/// Resultado consolidado del perfil de comportamiento del comprador
class BuyerBehaviorProfile {
  final String buyerId;

  // 1. Volumen habitual (Mediana)
  final double medianVolumeKg;
  final String volumeClassification; // 'Volumen bajo', 'Volumen medio', 'Volumen alto', 'Volumen mayorista'
  final int volumeConfidencePercent;
  final String volumeDisplay; // ej. "Semanal • 85 kg (Volumen medio)"

  // 2. Método de pago preferido
  final String preferredPaymentMethod;
  final int paymentConfidencePercent;
  final String paymentDisplay; // ej. "Transferencia SPEI Inmediata"

  // 3. Modalidad de compra
  final String purchaseModality; // 'Principalmente detalle', 'Mixto (Mayoreo y Detalle)', 'Principalmente mayorista'
  final int wholesaleIndexPercent;
  final int modalityConfidencePercent;

  // 4. Ranking de productos frecuentes con atenuación temporal
  final List<String> frequentProducts;
  final List<String> frequentCategories;

  // Total de operaciones analizadas
  final int totalPurchasesAnalyzed;

  const BuyerBehaviorProfile({
    required this.buyerId,
    required this.medianVolumeKg,
    required this.volumeClassification,
    required this.volumeConfidencePercent,
    required this.volumeDisplay,
    required this.preferredPaymentMethod,
    required this.paymentConfidencePercent,
    required this.paymentDisplay,
    required this.purchaseModality,
    required this.wholesaleIndexPercent,
    required this.modalityConfidencePercent,
    required this.frequentProducts,
    required this.frequentCategories,
    required this.totalPurchasesAnalyzed,
  });
}

/// Servicio encargado del cálculo algorítmico del comportamiento del comprador
class BuyerBehaviorService {
  static final BuyerBehaviorService instance = BuyerBehaviorService._internal();

  BuyerBehaviorService._internal() {
    _initMockHistory();
  }

  final List<BuyerPurchaseEvent> _purchaseHistory = [];

  void _initMockHistory() {
    final now = DateTime.now();

    // Historial para Juan Pérez (BUY-88291)
    // Demuestra el principio de la mediana: varias compras medianas y una compra atípica alta
    _purchaseHistory.addAll([
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-01',
        buyerId: 'BUY-88291',
        productName: 'Tomate Saladette',
        category: 'Hortalizas',
        quantityKg: 75,
        isWholesale: true,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 3)),
        amount: 1350.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-02',
        buyerId: 'BUY-88291',
        productName: 'Aguacate Hass',
        category: 'Aguacates',
        quantityKg: 40,
        isWholesale: false,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 6)),
        amount: 1800.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-03',
        buyerId: 'BUY-88291',
        productName: 'Limón Colima',
        category: 'Cítricos',
        quantityKg: 50,
        isWholesale: false,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 10)),
        amount: 850.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-04',
        buyerId: 'BUY-88291',
        productName: 'Tomate Saladette',
        category: 'Hortalizas',
        quantityKg: 85,
        isWholesale: true,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 14)),
        amount: 1530.0,
      ),
      // Compra excepcionalmente grande (atípica) que distorsionaría el promedio pero no la mediana
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-05',
        buyerId: 'BUY-88291',
        productName: 'Tomate Saladette',
        category: 'Hortalizas',
        quantityKg: 350,
        isWholesale: true,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 21)),
        amount: 5800.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-06',
        buyerId: 'BUY-88291',
        productName: 'Aguacate Hass',
        category: 'Aguacates',
        quantityKg: 60,
        isWholesale: true,
        paymentMethod: 'Efectivo',
        purchaseDate: now.subtract(const Duration(days: 28)),
        amount: 2700.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-07',
        buyerId: 'BUY-88291',
        productName: 'Cebolla Blanca',
        category: 'Hortalizas',
        quantityKg: 45,
        isWholesale: false,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 35)),
        amount: 720.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-JP-08',
        buyerId: 'BUY-88291',
        productName: 'Limón Colima',
        category: 'Cítricos',
        quantityKg: 55,
        isWholesale: true,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 42)),
        amount: 935.0,
      ),
    ]);

    // Historial para Mariana Ortiz (BUY-99102) - Mayorista
    _purchaseHistory.addAll([
      BuyerPurchaseEvent(
        orderId: 'ORD-MO-01',
        buyerId: 'BUY-99102',
        productName: 'Fresas Extras',
        category: 'Frutas',
        quantityKg: 450,
        isWholesale: true,
        paymentMethod: 'Contra Entrega',
        purchaseDate: now.subtract(const Duration(days: 2)),
        amount: 16200.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-MO-02',
        buyerId: 'BUY-99102',
        productName: 'Zanahorias',
        category: 'Hortalizas',
        quantityKg: 300,
        isWholesale: true,
        paymentMethod: 'Contra Entrega',
        purchaseDate: now.subtract(const Duration(days: 7)),
        amount: 5400.0,
      ),
      BuyerPurchaseEvent(
        orderId: 'ORD-MO-03',
        buyerId: 'BUY-99102',
        productName: 'Naranjas',
        category: 'Cítricos',
        quantityKg: 500,
        isWholesale: true,
        paymentMethod: 'Transferencia SPEI',
        purchaseDate: now.subtract(const Duration(days: 15)),
        amount: 7500.0,
      ),
    ]);
  }

  /// Calcula el perfil de comportamiento analítico de un comprador
  BuyerBehaviorProfile calculateProfile(String buyerId, {Map<String, dynamic>? fallbackData}) {
    final cleanId = buyerId.replaceAll('#', '').trim();
    final events = _purchaseHistory.where((e) => e.buyerId == cleanId).toList();

    if (events.isEmpty) {
      // Si no hay compras registradas aún, genera el perfil base parametrizado
      return _generateDefaultProfile(cleanId, fallbackData);
    }

    // 1. CÁLCULO DE VOLUMEN HABITUAL USANDO LA MEDIANA
    final quantities = events.map((e) => e.quantityKg).toList()..sort();
    final median = _calculateMedian(quantities);
    final volumeClassification = _classifyVolume(median);

    // Nivel de confianza del volumen: basado en cantidad de eventos y consistencia
    final volumeConfidence = min(96, max(60, (events.length * 9) + 25));
    final volumeDisplay = 'Semanal • ${median.round()} kg ($volumeClassification)';

    // 2. MÉTODO DE PAGO PREFERIDO Y CONFIANZA
    final paymentCounts = <String, int>{};
    for (var ev in events) {
      paymentCounts[ev.paymentMethod] = (paymentCounts[ev.paymentMethod] ?? 0) + 1;
    }
    var preferredPayment = 'Transferencia SPEI';
    var maxPaymentCount = 0;
    paymentCounts.forEach((method, count) {
      if (count > maxPaymentCount) {
        maxPaymentCount = count;
        preferredPayment = method;
      }
    });
    final paymentConfidence = ((maxPaymentCount / events.length) * 100).round();
    final paymentDisplay = (preferredPayment == 'Transferencia SPEI')
        ? 'Transferencia SPEI Inmediata'
        : preferredPayment;

    // 3. MODALIDAD DE COMPRA (ÍNDICE MAYORISTA)
    final wholesaleOrders = events.where((e) => e.isWholesale).length;
    final wholesaleIndex = ((wholesaleOrders / events.length) * 100).round();
    final purchaseModality = _classifyModality(wholesaleIndex);
    final modalityConfidence = min(95, max(65, 50 + (events.length * 6)));

    // 4. RANKING DE PRODUCTOS CON DECAIMIENTO TEMPORAL
    final now = DateTime.now();
    final productWeights = <String, double>{};
    final categoryWeights = <String, double>{};

    const lambda = 0.035; // Factor de decaimiento por día
    for (var ev in events) {
      final daysAgo = max(0, now.difference(ev.purchaseDate).inDays);
      final weight = exp(-lambda * daysAgo) * (ev.quantityKg / median);

      productWeights[ev.productName] = (productWeights[ev.productName] ?? 0) + weight;
      categoryWeights[ev.category] = (categoryWeights[ev.category] ?? 0) + weight;
    }

    final sortedProducts = productWeights.keys.toList()
      ..sort((a, b) => productWeights[b]!.compareTo(productWeights[a]!));
    final sortedCategories = categoryWeights.keys.toList()
      ..sort((a, b) => categoryWeights[b]!.compareTo(categoryWeights[a]!));

    return BuyerBehaviorProfile(
      buyerId: cleanId,
      medianVolumeKg: median,
      volumeClassification: volumeClassification,
      volumeConfidencePercent: volumeConfidence,
      volumeDisplay: volumeDisplay,
      preferredPaymentMethod: preferredPayment,
      paymentConfidencePercent: paymentConfidence,
      paymentDisplay: paymentDisplay,
      purchaseModality: purchaseModality,
      wholesaleIndexPercent: wholesaleIndex,
      modalityConfidencePercent: modalityConfidence,
      frequentProducts: sortedProducts.take(4).toList(),
      frequentCategories: sortedCategories.take(4).toList(),
      totalPurchasesAnalyzed: events.length,
    );
  }

  double _calculateMedian(List<double> sorted) {
    if (sorted.isEmpty) return 0.0;
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  String _classifyVolume(double medianKg) {
    if (medianKg <= 10) return 'Volumen bajo';
    if (medianKg <= 50) return 'Volumen medio';
    if (medianKg <= 200) return 'Volumen alto';
    return 'Volumen mayorista';
  }

  String _classifyModality(int wholesalePercentage) {
    if (wholesalePercentage <= 30) return 'Principalmente detalle';
    if (wholesalePercentage <= 65) return 'Ambos (Mayoreo y Detalle)';
    return 'Principalmente mayorista';
  }

  BuyerBehaviorProfile _generateDefaultProfile(String buyerId, Map<String, dynamic>? fallback) {
    final rawVolume = fallback?['purchaseVolume']?.toString() ?? 'Semanal • 75 kg (Volumen medio)';
    final rawPayment = fallback?['preferredPayment']?.toString() ?? 'Transferencia SPEI Inmediata';
    final rawModality = fallback?['preferredModality']?.toString() ?? 'Ambos (Mayoreo y Detalle)';
    final rawProducts = (fallback?['frequentProducts'] as List?)?.cast<String>() ??
        ['Tomate Saladette', 'Aguacate Hass', 'Limón Colima'];
    final rawCategories = (fallback?['frequentCategories'] as List?)?.cast<String>() ??
        ['Hortalizas', 'Frutas', 'Aguacates'];

    return BuyerBehaviorProfile(
      buyerId: buyerId,
      medianVolumeKg: 75.0,
      volumeClassification: 'Volumen medio',
      volumeConfidencePercent: 82,
      volumeDisplay: rawVolume,
      preferredPaymentMethod: rawPayment,
      paymentConfidencePercent: 78,
      paymentDisplay: rawPayment,
      purchaseModality: rawModality,
      wholesaleIndexPercent: 55,
      modalityConfidencePercent: 80,
      frequentProducts: rawProducts,
      frequentCategories: rawCategories,
      totalPurchasesAnalyzed: 8,
    );
  }

  /// Permite registrar una nueva compra completada en el sistema para actualizar dinámicamente el perfil
  void recordPurchase(BuyerPurchaseEvent event) {
    _purchaseHistory.insert(0, event);
  }
}
