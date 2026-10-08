enum PriceMarketStatus {
  cheap,      // Barato / Económico (oferta atractiva)
  fair,       // Justo / Competitivo (dentro del rango de mercado)
  expensive,  // Caro / Sobre el promedio de mercado
}

class PriceEvaluation {
  final PriceMarketStatus status;
  final double referencePrice;
  final double enteredPrice;
  final double percentageDiff; // e.g. +20.5% or -15.0%
  final String title;
  final String advice;

  const PriceEvaluation({
    required this.status,
    required this.referencePrice,
    required this.enteredPrice,
    required this.percentageDiff,
    required this.title,
    required this.advice,
  });

  bool get isExpensive => status == PriceMarketStatus.expensive;
  bool get isFair => status == PriceMarketStatus.fair;
  bool get isCheap => status == PriceMarketStatus.cheap;
}

class StandardCatalogProduct {
  final String id;
  final String name;
  final String category;
  final String defaultUnit;
  final String skuPrefix;
  final List<String> aliases;
  final double referenceRetailPrice;    // Precio promedio al detalle (Mercado)
  final double referenceWholesalePrice; // Precio promedio al por mayor (Merca / Centrales)
  final String? sampleImage;
  final String description;

  const StandardCatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultUnit,
    required this.skuPrefix,
    required this.aliases,
    required this.referenceRetailPrice,
    required this.referenceWholesalePrice,
    this.sampleImage,
    this.description = '',
  });

  /// Evalúa el precio ingresado por el proveedor frente al precio de referencia del mercado.
  /// Informa si el producto está caro, justo o barato para orientar al comerciante.
  PriceEvaluation evaluatePrice(double enteredPrice, {bool isWholesale = false}) {
    final ref = isWholesale ? referenceWholesalePrice : referenceRetailPrice;
    if (ref <= 0 || enteredPrice <= 0) {
      return PriceEvaluation(
        status: PriceMarketStatus.fair,
        referencePrice: ref,
        enteredPrice: enteredPrice,
        percentageDiff: 0,
        title: 'Sin datos de referencia',
        advice: 'Ingresa un precio para calcular la competitividad en el mercado.',
      );
    }

    final diffPercent = ((enteredPrice - ref) / ref) * 100.0;

    if (diffPercent > 15.0) {
      return PriceEvaluation(
        status: PriceMarketStatus.expensive,
        referencePrice: ref,
        enteredPrice: enteredPrice,
        percentageDiff: diffPercent,
        title: 'Precio por encima del mercado (Caro)',
        advice: 'Está un ${diffPercent.toStringAsFixed(1)}% más caro que el promedio (\$${ref.toStringAsFixed(2)}/$defaultUnit). Podría tener menor rotación de ventas.',
      );
    } else if (diffPercent < -15.0) {
      return PriceEvaluation(
        status: PriceMarketStatus.cheap,
        referencePrice: ref,
        enteredPrice: enteredPrice,
        percentageDiff: diffPercent,
        title: 'Precio de oportunidad (Económico)',
        advice: 'Está un ${diffPercent.abs().toStringAsFixed(1)}% por debajo del mercado (\$${ref.toStringAsFixed(2)}/$defaultUnit). ¡Excelente para atraer compradores rápidos!',
      );
    } else {
      return PriceEvaluation(
        status: PriceMarketStatus.fair,
        referencePrice: ref,
        enteredPrice: enteredPrice,
        percentageDiff: diffPercent,
        title: 'Precio competitivo (En rango de mercado)',
        advice: 'Tu precio está alineado con el mercado (\$${ref.toStringAsFixed(2)}/$defaultUnit). Es un valor justo para compradores y rentable para ti.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'defaultUnit': defaultUnit,
    'skuPrefix': skuPrefix,
    'aliases': aliases,
    'referenceRetailPrice': referenceRetailPrice,
    'referenceWholesalePrice': referenceWholesalePrice,
    'sampleImage': sampleImage,
    'description': description,
  };
}
