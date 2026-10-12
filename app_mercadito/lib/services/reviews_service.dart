import 'package:flutter/foundation.dart';

/// Representa una reseña asociada a un lote o producto negociado
class ProductNegotiationReview {
  final String orderId;
  final String negotiationId;
  final String productName;
  final String vendor;
  final bool vendorVerified;
  final String buyer;
  final String imageUrl;
  final DateTime completedDate;
  final String formattedCompletedDate;
  final String finalPrice;
  final String? originalPrice;
  final String quantity;
  final String totalAmount;
  final String? savings;
  final String? deliveryMethod;
  final String? paymentTerms;

  // Campos de la reseña del comprador
  int? rating;
  String? comment;
  List<String>? tags;
  String? userPhotoUrl;
  DateTime? reviewDate;

  // Campos de la respuesta del proveedor
  String? producerReply;
  DateTime? replyDate;

  ProductNegotiationReview({
    required this.orderId,
    required this.negotiationId,
    required this.productName,
    required this.vendor,
    this.vendorVerified = true,
    required this.buyer,
    required this.imageUrl,
    required this.completedDate,
    required this.formattedCompletedDate,
    required this.finalPrice,
    this.originalPrice,
    required this.quantity,
    required this.totalAmount,
    this.savings,
    this.deliveryMethod,
    this.paymentTerms,
    this.rating,
    this.comment,
    this.tags,
    this.userPhotoUrl,
    this.reviewDate,
    this.producerReply,
    this.replyDate,
  });

  /// Regla de negocio: la reseña solo se puede redactar a partir de 3 días después de la negociación
  bool get isReviewUnlocked {
    final difference = DateTime.now().difference(completedDate);
    return difference.inDays >= 3;
  }

  /// Días restantes para que se habilite la reseña
  int get daysRemaining {
    final diffDays = DateTime.now().difference(completedDate).inDays;
    final remaining = 3 - diffDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Indica si el comprador ya emitió su reseña
  bool get isReviewCompleted => rating != null && comment != null && comment!.isNotEmpty;

  /// Indica si el proveedor ya respondió a la reseña del comprador
  bool get isReplyCompleted => producerReply != null && producerReply!.trim().isNotEmpty;
}

/// Representa una reseña reputacional directa entre perfiles (Comprador <-> Proveedor)
class DirectProfileReview {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole; // 'comprador' o 'proveedor'
  final String? authorAvatar;
  final bool authorIsVerified;
  final String targetId;
  final String targetName;
  final String targetRole; // 'proveedor' o 'comprador'
  final String comment; // 10 a 100 caracteres
  final Map<String, double> scores;
  final double averageScore;
  final DateTime createdAt;

  DirectProfileReview({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    this.authorIsVerified = false,
    required this.targetId,
    required this.targetName,
    required this.targetRole,
    required this.comment,
    required this.scores,
    required this.averageScore,
    required this.createdAt,
  });
}

/// Métricas de velocidad y tasa de respuesta para un proveedor según la regla oficial
class ProviderResponseMetrics {
  final int averageResponseMinutes;
  final int speedScore; // 0-100% basado en la escala por tramos
  final int responseRate; // 0-100% conversaciones respondidas / recibidas
  final int compositeIndex; // Índice combinado de atención
  final String formattedResponseTime; // e.g. "8 minutos"
  final String statusLabel; // e.g. "⚡ Inmediata", "🟢 Muy rápida"

  const ProviderResponseMetrics({
    required this.averageResponseMinutes,
    required this.speedScore,
    required this.responseRate,
    required this.compositeIndex,
    required this.formattedResponseTime,
    required this.statusLabel,
  });

  /// Clasificación de puntos según tiempo en minutos (Sección 3 del documento)
  static int scoreForResponseMinutes(int minutes) {
    if (minutes <= 5) return 100; // ⚡ Inmediata
    if (minutes <= 15) return 90; // 🟢 Muy rápida
    if (minutes <= 30) return 75; // 🟢 Rápida
    if (minutes <= 60) return 50; // 🟡 Moderada
    if (minutes <= 120) return 25; // 🟠 Lenta
    return 0; // 🔴 Muy lenta
  }

  static String statusLabelForMinutes(int minutes) {
    if (minutes <= 5) return '⚡ Inmediata';
    if (minutes <= 15) return '🟢 Muy rápida';
    if (minutes <= 30) return '🟢 Rápida';
    if (minutes <= 60) return '🟡 Moderada';
    if (minutes <= 120) return '🟠 Lenta';
    return '🔴 Lenta';
  }

  /// Calcula las métricas a partir de una lista de atenciones recientes (ventana móvil)
  static ProviderResponseMetrics calculate({
    required List<int> responseTimesMinutes,
    required int totalConversationsReceived,
    required int totalConversationsAnswered,
  }) {
    if (responseTimesMinutes.isEmpty) {
      return const ProviderResponseMetrics(
        averageResponseMinutes: 8,
        speedScore: 95,
        responseRate: 98,
        compositeIndex: 96,
        formattedResponseTime: '8 minutos',
        statusLabel: '🟢 Muy rápida',
      );
    }

    // 1. Tiempo promedio
    final sumMinutes = responseTimesMinutes.fold<int>(0, (a, b) => a + b);
    final avgMinutes = (sumMinutes / responseTimesMinutes.length).round();

    // 2. Puntuación de rapidez por tramos
    final totalPoints = responseTimesMinutes.fold<int>(
      0,
      (sum, m) => sum + scoreForResponseMinutes(m),
    );
    final speed = (totalPoints / responseTimesMinutes.length).round().clamp(0, 100);

    // 3. Tasa de respuesta
    final rate = totalConversationsReceived > 0
        ? ((totalConversationsAnswered / totalConversationsReceived) * 100).round().clamp(0, 100)
        : 100;

    // 4. Índice compuesto (70% rapidez + 30% tasa de respuesta)
    final composite = ((speed * 0.7) + (rate * 0.3)).round().clamp(0, 100);

    final formattedTime = avgMinutes < 60
        ? '$avgMinutes minutos'
        : '${(avgMinutes / 60.0).toStringAsFixed(1)} horas';

    return ProviderResponseMetrics(
      averageResponseMinutes: avgMinutes,
      speedScore: speed,
      responseRate: rate,
      compositeIndex: composite,
      formattedResponseTime: formattedTime,
      statusLabel: statusLabelForMinutes(avgMinutes),
    );
  }
}

/// Servicio centralizado de reseñas de negociaciones y reputación directa
class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  // ---------------------------------------------------------------------------
  // 1. Reseñas de Productos Negociados (Comprador y Proveedor)
  // ---------------------------------------------------------------------------

  final List<ProductNegotiationReview> _negotiationReviews = _createDefaultNegotiationReviews();

  static List<ProductNegotiationReview> _createDefaultNegotiationReviews() => [
    // 1. Acuerdo completado hace 4 días (>= 3 días -> HABILITADO para el comprador)
    ProductNegotiationReview(
      orderId: '#NEG-00001',
      negotiationId: 'NEG-00001',
      productName: 'Tomates Heirloom',
      vendor: 'Finca La Esperanza',
      vendorVerified: true,
      buyer: 'Juan Pérez',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      completedDate: DateTime.now().subtract(const Duration(days: 4)),
      formattedCompletedDate: 'Hace 4 días',
      finalPrice: '\$1.80/kg',
      originalPrice: '\$2.20/kg',
      quantity: '150 kg',
      totalAmount: '\$270.00',
      savings: '\$60.00',
      deliveryMethod: 'Entrega directa en bodega',
      paymentTerms: 'Contra entrega • Factura aprobada',
    ),
    // 2. Acuerdo completado ayer (1 día < 3 días -> BLOQUEADO para el comprador, faltan 2 días)
    ProductNegotiationReview(
      orderId: '#NEG-00002',
      negotiationId: 'NEG-00002',
      productName: 'Miel Silvestre',
      vendor: 'Apicultura Los Pinos',
      vendorVerified: true,
      buyer: 'Juan Pérez',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      completedDate: DateTime.now().subtract(const Duration(days: 1)),
      formattedCompletedDate: 'Ayer',
      finalPrice: '\$8.50/frasco',
      originalPrice: '\$10.00/frasco',
      quantity: '20 frascos',
      totalAmount: '\$170.00',
      savings: '\$30.00',
      deliveryMethod: 'Envío asegurado en cajas especiales',
      paymentTerms: 'Transferencia bancaria previa',
    ),
    // 3. Acuerdo completado hace 2 días (2 días < 3 días -> BLOQUEADO, falta 1 día)
    ProductNegotiationReview(
      orderId: '#NEG-00003',
      negotiationId: 'NEG-00003',
      productName: 'Queso Curado',
      vendor: 'Lácteos del Valle',
      vendorVerified: true,
      buyer: 'Juan Pérez',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjdenPCC0s2roiOH2l6Sz2N-rAy2Z5-g76EAQ8oY8i6fZ5WyY2RRz3m5HRw-qieLTCWthbVvW_NkOtrz91LyjbwmmFV3VWJCDt0pchBuJrLF59mdAp64Rn-cCXRH2AIoNWH4L9A2VYArB1_irCME483PC-rXFcRaoC0hmqStlNSBMRqPK9gbl78IDP5FVW173bEhD9BhIOUJQeqA2wimkZJkE_AjWeDrXQdWreMOCFy5wZuNYYGotHD0NLXVKdDdHHms4qWYhrVOc',
      completedDate: DateTime.now().subtract(const Duration(days: 2)),
      formattedCompletedDate: 'Hace 2 días',
      finalPrice: '\$12.00/pieza',
      originalPrice: '\$14.50/pieza',
      quantity: '15 piezas',
      totalAmount: '\$180.00',
      savings: '\$37.50',
      deliveryMethod: 'Cadena de frío controlada',
      paymentTerms: 'Crédito a 15 días tras recepción',
    ),
    // 4. Reseña ya completada por el comprador pero SIN respuesta del vendedor (Pendiente para el Proveedor)
    ProductNegotiationReview(
      orderId: '#NEG-00004',
      negotiationId: 'NEG-00004',
      productName: 'Cesta de Verduras Mixtas',
      vendor: 'Finca La Esperanza',
      vendorVerified: true,
      buyer: 'Mariana Ortiz',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      completedDate: DateTime.now().subtract(const Duration(days: 10)),
      formattedCompletedDate: '10 de Mayo, 2026',
      finalPrice: '\$25.00/cesta',
      originalPrice: '\$30.00/cesta',
      quantity: '2 cestas',
      totalAmount: '\$50.00',
      rating: 5,
      comment: 'Excelente calidad, todo muy fresco. Los pimientos estaban espectaculares y el empaque muy cuidadoso.',
      tags: ['Excelente calidad', 'Frescura garantizada', 'Empaque cuidadoso'],
      userPhotoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDkExJjnogapAzYJSb7dQcgEWoBPwi2xrSMgswCUDDdVdRIXBZrVUKFDHMFPh8uh9DUS0PoOVg9IrZX3QGXegq2vzNujlg8qkX9oTAilz4-qbfjAC8xvPkNtl_X5ZFNpvFUAB6cbjL0rQECyadtUul-xcUGi73dT-_8e1Rr3QDvasFOTid1uiY8_3qwe0DHWwWnt-yKwa_USTLTgTbZYGYoRW7zLXOSazPfHD2Ouw_9Onw8CMHvzMiClYcBiFiabXucIHwkS4Ts75c',
      producerReply: null, // PENDIENTE DE RESPONDER POR EL PROVEEDOR
    ),
    // 5. Reseña completada por el comprador y YA respondida por el vendedor (Completada para ambos)
    ProductNegotiationReview(
      orderId: '#NEG-00005',
      negotiationId: 'NEG-00005',
      productName: 'Aceite de Oliva Virgen Extra',
      vendor: 'Finca La Esperanza',
      vendorVerified: true,
      buyer: 'Carlos Ruiz',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCXVjjLbAdq-qPVQ_4K3NOYusCymD1EzqS1kC-Lo2r8QtaXyo5pkWNSGVhL5GRtQdbQGSokSKklmFZQkqOdUI4YyvMbTzXiN4AXEBPr5cPtwmDPhu-Xq-fe5DmDEQ7bb12IupTY6GlguVCGhQguSo9BlaDDC8cklW1Mk-PM8CK-6xz9XhSIfBgoT5YJi9nx55BRZ0yONRnrZSQ4Xft817qS_jLiuOtjEbCKVWGb-EVrUn1Ker8c_Z-DsulYXVud8E41W1UHegQnM4Q',
      completedDate: DateTime.now().subtract(const Duration(days: 20)),
      formattedCompletedDate: '28 de Abril, 2026',
      finalPrice: '\$14.00/botella',
      originalPrice: '\$16.50/botella',
      quantity: '5 botellas',
      totalAmount: '\$70.00',
      rating: 4,
      comment: 'Muy buen sabor, intenso y con toques frutales. Ideal para ensaladas.',
      tags: ['Buen sabor', 'Puntualidad'],
      userPhotoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDP2SAhDf3xiSDi_M640MlgD1SQS_efXAy3Nge5f61w_PC0JqfPVQnJ_kzRN9OgQrCitc4c0LnJKeKKJHU00mVz4zapAJiBALXB2tF9-vkiIl8iYScPOcNMZwg2qMrHJfOf4och7hchrTrvSDLEMP3wTPctSP4iDgSaaRlygMLAx9hQgab4WuZ3LM2naJkAN4LC7H4CrZZrEyxehsOObIA6mq_8FYKPBB7xwkEQ9p6uL63m30AzftO3X0FNrF6k_45fChAU1ky479Y',
      producerReply: '¡Muchas gracias Carlos! Cuidamos cada detalle en la prensa de las olivas para garantizar ese perfil frutal único. - Finca La Esperanza',
      replyDate: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ];

  /// Notificador para actualizar vistas reactivamente
  final ValueNotifier<int> reviewsRevision = ValueNotifier(0);

  // ---------------------------------------------------------------------------
  // Métodos para el Comprador
  // ---------------------------------------------------------------------------

  /// Acuerdos que el comprador tiene pendientes por calificar
  List<ProductNegotiationReview> getBuyerPendingReviews() {
    return _negotiationReviews.where((item) => !item.isReviewCompleted).toList();
  }

  /// Acuerdos que el comprador ya ha calificado
  List<ProductNegotiationReview> getBuyerCompletedReviews() {
    return _negotiationReviews.where((item) => item.isReviewCompleted).toList();
  }

  /// Envía la reseña de un comprador para un producto negociado
  bool submitBuyerReview({
    required String orderId,
    required int rating,
    required String comment,
    required List<String> tags,
    String? userPhotoUrl,
  }) {
    final index = _negotiationReviews.indexWhere((r) => r.orderId == orderId);
    if (index == -1) return false;

    final review = _negotiationReviews[index];
    if (!review.isReviewUnlocked) {
      return false; // Bloqueado por regla de 3 días
    }

    review.rating = rating;
    review.comment = comment;
    review.tags = List.from(tags);
    review.userPhotoUrl = userPhotoUrl;
    review.reviewDate = DateTime.now();

    reviewsRevision.value++;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Métodos para el Proveedor
  // ---------------------------------------------------------------------------

  /// Reseñas completadas por compradores que están pendientes de respuesta del proveedor
  List<ProductNegotiationReview> getProviderPendingReviews() {
    return _negotiationReviews
        .where((item) => item.isReviewCompleted && !item.isReplyCompleted)
        .toList();
  }

  /// Reseñas que ya fueron respondidas por el proveedor
  List<ProductNegotiationReview> getProviderCompletedReviews() {
    return _negotiationReviews
        .where((item) => item.isReviewCompleted && item.isReplyCompleted)
        .toList();
  }

  /// El proveedor responde a una reseña pendiente de un comprador
  bool submitProviderReply({
    required String orderId,
    required String replyText,
  }) {
    final index = _negotiationReviews.indexWhere((r) => r.orderId == orderId);
    if (index == -1) return false;

    final review = _negotiationReviews[index];
    review.producerReply = replyText.trim();
    review.replyDate = DateTime.now();

    reviewsRevision.value++;
    return true;
  }

  // ---------------------------------------------------------------------------
  // 2. Reseñas Directas de Perfiles (Proveedor <-> Comprador)
  // ---------------------------------------------------------------------------

  final List<DirectProfileReview> _directReviews = _createDefaultDirectReviews();

  static List<DirectProfileReview> _createDefaultDirectReviews() => [
    // Reseñas de compradores hacia el proveedor "Finca La Esperanza" / Andherson Diaz
    DirectProfileReview(
      id: 'DIR-REV-101',
      authorId: 'BUY-88291',
      authorName: 'Mariana Ortiz',
      authorRole: 'comprador',
      authorAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBYJzD8Jv__HCofoE_9GXHz6ThLuAmE4GY780JgKF_CnF0e0Ag7eeBdUuo91rwB6Zu0SQvC0ZQxHfm-2ptRUB-8M06caS-RMrBIzj8QHpqkj5QX6vhBO9445gMwzqiu6Yt5juCbYloMuTe9AcbgO7tyDHdemyOCuU_oA7_LQpePOm4X00XfFhNY8SIY-x6DalOZ5-JMFeO2FTK_BoTu-2i9_A-FY9mHZui7BXNQCnwMBtaGINBTm0JmtYFeZAcAz2D5DX2EJlMSLnM',
      targetId: 'PROV-1',
      targetName: 'Finca La Esperanza',
      targetRole: 'proveedor',
      comment: 'Excelente socio comercial, puntualidad intachable en cada carga y producto fresco siempre.',
      scores: {
        'Recomendación': 4.8,
        'Calidad del servicio': 4.9,
        'Puntualidad': 4.8,
        'Comunicación': 4.9,
        'Cumplimiento': 4.9,
        'Confiabilidad': 4.8,
        'Correspondencia con lo ofrecido': 4.7,
      },
      averageScore: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-102',
      authorId: 'BUY-99102',
      authorName: 'Roberto G.',
      authorRole: 'comprador',
      authorAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC86MsmWl10UM74dTqXN5cvWFEfmYUHsvKCR-y0wD2lYq9QbU1pPOuisx8V-kTEWaa2qDlT0WLBok7LgAyVI4oYfdDfTjkty2sjutfWf8TgR-dczjEg_hjEjyNx_Jt4gpAXDFR7Dgw2FV4_Lhg89Dm7gXQfTgCGY6TtUH9-Gra8NJFrRaoI6KS_t8z3wZKcmelvinox1Ah-7VlOqLa6B1FsrxJQwJPtzLlVN6e8tC5R9kIwziSN6peMLip0X-9igzwYS5lNu2tOSA0',
      targetId: 'PROV-1',
      targetName: 'Finca La Esperanza',
      targetRole: 'proveedor',
      comment: 'Muy responsable y atento con los horarios de entrega pactados. Muy recomendado.',
      scores: {
        'Recomendación': 4.8,
        'Calidad del servicio': 4.9,
        'Puntualidad': 4.8,
        'Comunicación': 4.9,
        'Cumplimiento': 4.9,
        'Confiabilidad': 4.8,
        'Correspondencia con lo ofrecido': 4.7,
      },
      averageScore: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),

    // Reseñas de proveedores hacia el comprador "Juan Pérez"
    DirectProfileReview(
      id: 'DIR-REV-201',
      authorId: 'PROV-1',
      authorName: 'Finca La Esperanza',
      authorRole: 'proveedor',
      authorAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1u8etbY5cHiRod_Fsz0_cuGTPBYf1Kj3M9WWtxHKJPGQ80EV82hmsmCV_Gt93yIiAAYRrHcpjpcGQvWY6oCOXHF5JcfmhpwXq5fj6OyrK4y_GaFvJgKHtBGGRbV3fH5b06o4tW0WeCL9448PUxQhHSfSX58eVK_lx7JUhms8WnRMbpDqcWul-oB60GyFZHNBDb6ouVvsT47SpGzBpuWhNyUDtZ7iBTFmBGB6DtwzTd28a4GMKjluGv3yihiGBfs1OZehh14Ktak',
      authorIsVerified: true,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Comprador muy serio y puntual con sus pagos acordados. Es un placer hacer negocios.',
      scores: {
        'Comunicación': 5.0,
        'Puntualidad': 5.0,
        'Cumplimiento del acuerdo': 5.0,
        'Cumplimiento de pago': 5.0,
        'Seriedad en la compra': 5.0,
        'Comportamiento general': 5.0,
      },
      averageScore: 5.0,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-202',
      authorId: 'PROV-2',
      authorName: 'Apicultura Los Pinos',
      authorRole: 'proveedor',
      authorIsVerified: true,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Excelente comunicación y claridad en la recepción del cargamento. Muy formal.',
      scores: {
        'Comunicación': 5.0,
        'Puntualidad': 4.0,
        'Cumplimiento del acuerdo': 5.0,
        'Cumplimiento de pago': 5.0,
        'Seriedad en la compra': 5.0,
        'Comportamiento general': 5.0,
      },
      averageScore: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-203',
      authorId: 'PROV-3',
      authorName: 'Agropecuaria del Bajío',
      authorRole: 'proveedor',
      authorIsVerified: false,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Recepción ordenada y buen entendimiento comercial durante todo el proceso.',
      scores: {
        'Comunicación': 4.8,
        'Puntualidad': 4.5,
        'Cumplimiento del acuerdo': 4.9,
        'Cumplimiento de pago': 5.0,
        'Seriedad en la compra': 4.9,
        'Comportamiento general': 4.8,
      },
      averageScore: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-204',
      authorId: 'PROV-4',
      authorName: 'Huertos San José',
      authorRole: 'proveedor',
      authorIsVerified: true,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Excelente comprador. Pedidos con especificaciones precisas y pago inmediato.',
      scores: {
        'Comunicación': 5.0,
        'Puntualidad': 4.8,
        'Cumplimiento del acuerdo': 5.0,
        'Cumplimiento de pago': 5.0,
        'Seriedad en la compra': 5.0,
        'Comportamiento general': 5.0,
      },
      averageScore: 5.0,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-205',
      authorId: 'PROV-5',
      authorName: 'Distribuidora Lácteos del Valle',
      authorRole: 'proveedor',
      authorIsVerified: false,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Descarga eficiente y trato muy cordial por parte del equipo en almacén.',
      scores: {
        'Comunicación': 4.6,
        'Puntualidad': 4.5,
        'Cumplimiento del acuerdo': 4.7,
        'Cumplimiento de pago': 4.8,
        'Seriedad en la compra': 4.8,
        'Comportamiento general': 4.7,
      },
      averageScore: 4.7,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-206',
      authorId: 'PROV-6',
      authorName: 'Hortalizas Don Pepe',
      authorRole: 'proveedor',
      authorIsVerified: true,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Muy recomendable para hacer tratos semanales. Pagador transparente y confiable.',
      scores: {
        'Comunicación': 5.0,
        'Puntualidad': 5.0,
        'Cumplimiento del acuerdo': 5.0,
        'Cumplimiento de pago': 5.0,
        'Seriedad en la compra': 5.0,
        'Comportamiento general': 5.0,
      },
      averageScore: 5.0,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    DirectProfileReview(
      id: 'DIR-REV-207',
      authorId: 'PROV-7',
      authorName: 'Cooperativa San Marcos',
      authorRole: 'proveedor',
      authorIsVerified: false,
      targetId: 'BUY-88291',
      targetName: 'Juan Pérez',
      targetRole: 'comprador',
      comment: 'Trato profesional y buena disposición para coordinar los horarios de entrega.',
      scores: {
        'Comunicación': 4.7,
        'Puntualidad': 4.6,
        'Cumplimiento del acuerdo': 4.8,
        'Cumplimiento de pago': 4.9,
        'Seriedad en la compra': 4.8,
        'Comportamiento general': 4.7,
      },
      averageScore: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 42)),
    ),
  ];

  /// Comprueba si el usuario ya escribió una reseña directa a este objetivo
  bool hasWrittenDirectReview({
    required String authorId,
    required String targetId,
  }) {
    return _directReviews.any(
      (r) => r.authorId == authorId && r.targetId == targetId,
    );
  }

  /// Verifica si el usuario tiene permiso para escribir una reseña directa
  /// (debe haber negociado al menos una vez con la contraparte y no haber escrito una previa)
  bool canWriteDirectReview({
    required String authorId,
    required String authorRole,
    required String targetId,
    required String targetRole,
    bool hasNegotiated = true,
  }) {
    // 1. Roles cruzados: comprador solo a proveedor, proveedor solo a comprador
    if (authorRole == targetRole) return false;
    // 2. Debe haber negociado al menos 1 vez
    if (!hasNegotiated) return false;
    // 3. Solo 1 reseña directa permitida
    if (hasWrittenDirectReview(authorId: authorId, targetId: targetId)) return false;
    return true;
  }

  /// Registra una nueva reseña directa
  bool submitDirectReview({
    required String authorId,
    required String authorName,
    required String authorRole,
    String? authorAvatar,
    bool? authorIsVerified,
    required String targetId,
    required String targetName,
    required String targetRole,
    required String comment,
    required Map<String, double> scores,
    bool allowUpdate = false,
  }) {
    // Validar comentario (10 a 100 caracteres)
    final cleanComment = comment.trim();
    if (cleanComment.length < 10 || cleanComment.length > 100) {
      return false;
    }

    final existingIndex = _directReviews.indexWhere(
      (r) => r.authorId == authorId && r.targetId == targetId,
    );

    if (existingIndex != -1 && !allowUpdate) {
      return false;
    }

    // Calcular promedio
    double sum = 0;
    scores.forEach((key, value) {
      sum += value;
    });
    final average = scores.isNotEmpty ? (sum / scores.length) : 5.0;
    final roundedAverage = double.parse(average.toStringAsFixed(1));

    final isVerified = authorIsVerified ??
        (authorRole == 'proveedor' &&
            (authorId == 'PROV-1' ||
                authorName.contains('Finca') ||
                authorName.contains('Esperanza')));

    final newReview = DirectProfileReview(
      id: existingIndex != -1
          ? _directReviews[existingIndex].id
          : 'DIR-REV-${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      authorIsVerified: isVerified,
      targetId: targetId,
      targetName: targetName,
      targetRole: targetRole,
      comment: cleanComment,
      scores: Map.from(scores),
      averageScore: roundedAverage,
      createdAt: DateTime.now(),
    );

    if (existingIndex != -1) {
      _directReviews[existingIndex] = newReview;
    } else {
      _directReviews.insert(0, newReview);
    }
    reviewsRevision.value++;
    return true;
  }


  /// Reseñas directas dirigidas a un objetivo
  List<DirectProfileReview> getDirectReviewsForTarget(String targetId) {
    return _directReviews.where((r) =>
      r.targetId == targetId ||
      ((targetId == 'prov_granja_sol' || targetId == '#PRO-88291') && r.targetId == 'PROV-1') ||
      (targetId == 'PROV-1' && r.targetId == 'prov_granja_sol')
    ).toList();
  }

  /// Métricas de velocidad de respuesta para el proveedor
  ProviderResponseMetrics getProviderResponseMetrics(String providerId) {
    // Ventana móvil de atenciones recientes del proveedor
    return ProviderResponseMetrics.calculate(
      responseTimesMinutes: const [5, 10, 4, 8, 6, 12, 5, 7, 10, 6],
      totalConversationsReceived: 50,
      totalConversationsAnswered: 49,
    );
  }

  /// Obtiene los 7 criterios exactos para el perfil del proveedor con sus calificaciones medias
  Map<String, double> getProviderCriteriaScores(String providerId) {
    final reviews = _directReviews.where((r) => r.targetId == providerId).toList();
    if (reviews.isEmpty) {
      return {
        'Recomendación': 4.8,
        'Calidad del servicio': 4.9,
        'Puntualidad': 4.8,
        'Comunicación': 4.9,
        'Cumplimiento': 4.9,
        'Confiabilidad': 4.8,
        'Correspondencia con lo ofrecido': 4.7,
      };
    }

    double rec = 0, cal = 0, punt = 0, com = 0, cump = 0, conf = 0, corr = 0;
    int count = reviews.length;

    for (var r in reviews) {
      rec += r.scores['Recomendación'] ?? 4.8;
      cal += r.scores['Calidad del servicio'] ?? 4.9;
      punt += r.scores['Puntualidad'] ?? 4.8;
      com += r.scores['Comunicación'] ?? 4.9;
      cump += r.scores['Cumplimiento'] ?? 4.9;
      conf += r.scores['Confiabilidad'] ?? 4.8;
      corr += r.scores['Correspondencia con lo ofrecido'] ?? 4.7;
    }

    return {
      'Recomendación': double.parse((rec / count).toStringAsFixed(1)),
      'Calidad del servicio': double.parse((cal / count).toStringAsFixed(1)),
      'Puntualidad': double.parse((punt / count).toStringAsFixed(1)),
      'Comunicación': double.parse((com / count).toStringAsFixed(1)),
      'Cumplimiento': double.parse((cump / count).toStringAsFixed(1)),
      'Confiabilidad': double.parse((conf / count).toStringAsFixed(1)),
      'Correspondencia con lo ofrecido': double.parse((corr / count).toStringAsFixed(1)),
    };
  }

  /// Métricas agregadas para el perfil del proveedor
  Map<String, dynamic> getProviderReputationMetrics(String providerId) {
    final directReviews = _directReviews.where((r) => r.targetId == providerId).toList();
    final directCount = directReviews.length;

    // Obtener notas medias de los 7 criterios exactos
    final criteriaScores = getProviderCriteriaScores(providerId);

    // Cumplimiento calculado a partir de la media del criterio 'Cumplimiento'
    final complianceScore = criteriaScores['Cumplimiento'] ?? 4.9;
    final compliancePercent = ((complianceScore / 5.0) * 100).round().clamp(0, 100);

    // Recomendación calculada a partir de la media del criterio 'Recomendación'
    final recommendationScore = criteriaScores['Recomendación'] ?? 4.8;
    final recommendationPercent = ((recommendationScore / 5.0) * 100).round().clamp(0, 100);

    // Métricas de respuesta rápida calculadas según el documento de reglas
    final responseMetrics = getProviderResponseMetrics(providerId);

    // Overall rating
    double sumScores = 0;
    criteriaScores.forEach((_, val) => sumScores += val);
    final overallRating = double.parse((sumScores / criteriaScores.length).toStringAsFixed(1));

    return {
      'overallRating': overallRating,
      'totalReviews': 127 + directCount,
      'compliancePercent': compliancePercent,
      'fastResponsePercent': responseMetrics.speedScore,
      'recommendationPercent': recommendationPercent,
      'average': overallRating,
      'cumplimiento': compliancePercent,
      'respuestaRapida': responseMetrics.speedScore,
      'recomendacion': recommendationPercent,
      'estimatedResponseMinutes': responseMetrics.averageResponseMinutes,
      'formattedResponseTime': responseMetrics.formattedResponseTime,
      'responseMetrics': responseMetrics,
    };
  }

  /// Métricas agregadas para el perfil del comprador: "¿Cómo lo califican los proveedores?"
  Map<String, double> getBuyerReputationScores(String buyerId) {
    final reviews = _directReviews.where((r) => r.targetId == buyerId).toList();
    if (reviews.isEmpty) {
      return {
        'Comunicación': 4.9,
        'Cumplimiento': 4.8,
        'Puntualidad': 4.7,
        'Trato': 5.0,
        'Pago': 4.9,
        'Cumplimiento del acuerdo': 4.8,
        'Cumplimiento de pago': 4.9,
        'Seriedad en la compra': 5.0,
        'Comportamiento general': 4.9,
      };
    }

    double com = 0, cump = 0, punt = 0, trat = 0, pag = 0, ser = 0;
    int count = reviews.length;

    for (var r in reviews) {
      com += r.scores['Comunicación'] ?? 5.0;
      cump += r.scores['Cumplimiento del acuerdo'] ?? (r.scores['Cumplimiento'] ?? 5.0);
      punt += r.scores['Puntualidad'] ?? 5.0;
      trat += r.scores['Comportamiento general'] ?? (r.scores['Trato'] ?? 5.0);
      ser += r.scores['Seriedad en la compra'] ?? (r.scores['Trato'] ?? 5.0);
      pag += r.scores['Cumplimiento de pago'] ?? (r.scores['Pago'] ?? 5.0);
    }

    final comAvg = double.parse((com / count).toStringAsFixed(1));
    final cumpAvg = double.parse((cump / count).toStringAsFixed(1));
    final puntAvg = double.parse((punt / count).toStringAsFixed(1));
    final tratAvg = double.parse((trat / count).toStringAsFixed(1));
    final pagAvg = double.parse((pag / count).toStringAsFixed(1));
    final serAvg = double.parse((ser / count).toStringAsFixed(1));

    return {
      'Comunicación': comAvg,
      'Cumplimiento': cumpAvg,
      'Puntualidad': puntAvg,
      'Trato': tratAvg,
      'Pago': pagAvg,
      'Cumplimiento del acuerdo': cumpAvg,
      'Cumplimiento de pago': pagAvg,
      'Seriedad en la compra': serAvg,
      'Comportamiento general': tratAvg,
    };
  }

  // Static convenience accessors
  static Map<String, dynamic> getProviderReputation(String providerId) =>
      instance.getProviderReputationMetrics(providerId);

  static Map<String, double> getProviderCriteria(String providerId) =>
      instance.getProviderCriteriaScores(providerId);

  static ProviderResponseMetrics getProviderResponse(String providerId) =>
      instance.getProviderResponseMetrics(providerId);

  static Map<String, double> getBuyerReputation(String buyerId) =>
      instance.getBuyerReputationScores(buyerId);

  static bool hasDirectReview(String authorId, String targetId) =>
      instance.hasWrittenDirectReview(authorId: authorId, targetId: targetId);

  static List<DirectProfileReview> getDirectReviews(String targetId) =>
      instance.getDirectReviewsForTarget(targetId);

  static bool hasNegotiatedWith(String authorId, String targetId) => true;

  /// Reinicia a valores iniciales (para pruebas)
  void reset() {
    _negotiationReviews.clear();
    _negotiationReviews.addAll(_createDefaultNegotiationReviews());
    _directReviews.clear();
    _directReviews.addAll(_createDefaultDirectReviews());
    reviewsRevision.value++;
  }
}
