enum MarketTrendType {
  up, // Alza
  down, // Baja
  stable, // Estable
}

class MarketNewsItem {
  final String id;
  final String title;
  final String summary;
  final String commercialAnalysis;
  final String sourceName;
  final String sourceUrl;
  final String publishedAt;
  final String category; // 'Frutas', 'Vegetales', 'Granos', 'Comercialización', 'Clima'
  final MarketTrendType trend;
  final String trendImpact;
  final List<String> relatedProducts;
  final String imageUrl;
  final int readTimeMinutes;

  const MarketNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.commercialAnalysis,
    required this.sourceName,
    required this.sourceUrl,
    required this.publishedAt,
    required this.category,
    required this.trend,
    required this.trendImpact,
    required this.relatedProducts,
    required this.imageUrl,
    this.readTimeMinutes = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'commercialAnalysis': commercialAnalysis,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'publishedAt': publishedAt,
      'category': category,
      'trend': trend.name,
      'trendImpact': trendImpact,
      'relatedProducts': relatedProducts,
      'imageUrl': imageUrl,
      'readTimeMinutes': readTimeMinutes,
    };
  }
}

class CropTrendPrediction {
  final String cropName;
  final String category; // 'Frutas', 'Vegetales', 'Granos', 'Tubérculos', 'Víveres'
  final String direction; // 'alza', 'baja', 'sin_cambios'
  final String percentageTag; // '+7.5%', '-6.0%', 'Sin cambios'
  final String forecastSummary;
  final String confidenceLevel; // 'Alta', 'Media', 'En observación'
  final String timeHorizon; // 'Próximos 15-30 días'
  final bool hasData; // true si cuenta con noticias/datos recientes, false si no existen datos suficientes
  final String? sourceName;
  final String? sourceUrl;

  const CropTrendPrediction({
    required this.cropName,
    required this.category,
    required this.direction,
    required this.percentageTag,
    required this.forecastSummary,
    required this.confidenceLevel,
    required this.timeHorizon,
    required this.hasData,
    this.sourceName,
    this.sourceUrl,
  });
}

