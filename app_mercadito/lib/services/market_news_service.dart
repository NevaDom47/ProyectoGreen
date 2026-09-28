import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/market_news_model.dart';

class MarketNewsService {
  MarketNewsService._internal();
  static final MarketNewsService instance = MarketNewsService._internal();

  final List<MarketNewsItem> _news = [
    const MarketNewsItem(
      id: 'news-001',
      title: 'Aguacate Hass: Demanda récord en Norteamérica y Europa eleva precios en origen',
      summary:
          'El repunte sostenido del consumo internacional y la preferencia por calibres medianos y grandes han acelerado los contratos de compra directa en finca, fortaleciendo los márgenes para productores certificados.',
      commercialAnalysis:
          'Se anticipa una tendencia alcista (+6% a +9%) para el próximo mes en precios al productor. Oportunidad ideal para productores organizados que cumplan estándares de empaque y buenas prácticas.',
      sourceName: 'Portal Frutícola',
      sourceUrl: 'https://www.portalfruticola.com/noticias/',
      publishedAt: 'Hoy, 09:15 AM',
      category: 'Frutas',
      trend: MarketTrendType.up,
      trendImpact: 'Alza de precios (+7.5%)',
      relatedProducts: ['Aguacate Hass', 'Frutas de Exportación'],
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600',
      readTimeMinutes: 3,
    ),
    const MarketNewsItem(
      id: 'news-002',
      title: 'Tomate Saladette e Industrial: Pico de cosecha en valles productivos incrementa la oferta mayorista',
      summary:
          'El ingreso masivo de cosechas desde las principales zonas bajo riego ha saturado temporalmente los canales de abastecimiento en los mercados centrales, provocando una corrección a la baja en los precios por caja.',
      commercialAnalysis:
          'Presión bajista inmediata en mercados mayoristas (-5% a -8%). Se recomienda a los comerciantes programar compras escalonadas y a los productores explorar venta por volumen o transformación agroindustrial.',
      sourceName: 'FreshPlaza Agro',
      sourceUrl: 'https://www.freshplaza.es/',
      publishedAt: 'Hoy, 08:30 AM',
      category: 'Vegetales',
      trend: MarketTrendType.down,
      trendImpact: 'Baja moderada (-6.0%)',
      relatedProducts: ['Tomate Saladette', 'Tomate Bola', 'Vegetales'],
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600',
      readTimeMinutes: 4,
    ),
    const MarketNewsItem(
      id: 'news-003',
      title: 'Arroz y Granos Básicos: Productores y molineros reportan inventarios estables y abastecimiento garantizado',
      summary:
          'El balance nacional de granos confirma existencias suficientes para satisfacer la demanda de los próximos seis meses sin variaciones abruptas, garantizando predictibilidad tanto para distribuidores como para consumidores.',
      commercialAnalysis:
          'Estabilidad de precios en el mediano plazo (variación estimada menor al 1%). El mercado mayorista mantiene márgenes comerciales previsibles con flujo continuo en pedidos por quintal.',
      sourceName: 'FAO Noticias Agropecuarias',
      sourceUrl: 'https://www.fao.org/newsroom/es',
      publishedAt: 'Ayer, 04:45 PM',
      category: 'Granos',
      trend: MarketTrendType.stable,
      trendImpact: 'Precios estables (±0.5%)',
      relatedProducts: ['Arroz Campo', 'Arroz Selecto', 'Granos'],
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      readTimeMinutes: 3,
    ),
    const MarketNewsItem(
      id: 'news-004',
      title: 'Plátano y Musáceas: Fuerte dinamismo en mercados centrales con alta rotación comercial',
      summary:
          'La excelente recuperación de las plantaciones y la alta demanda de restaurantes, comedores y supermercados mantienen un flujo constante de camiones de carga hacia los principales centros de acopio.',
      commercialAnalysis:
          'Tendencia comercial favorable con incremento gradual en precio por millar (+3% a +5%). El plátano verde mantiene la rotación más veloz entre los víveres de la canasta agropecuaria.',
      sourceName: 'Mercado Agro Central',
      sourceUrl: 'https://www.infoagro.com/',
      publishedAt: 'Ayer, 11:20 AM',
      category: 'Comercialización',
      trend: MarketTrendType.up,
      trendImpact: 'Alta demanda (+4.0%)',
      relatedProducts: ['Plátano Verde', 'Guineo Maduro', 'Víveres'],
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600',
      readTimeMinutes: 2,
    ),
    const MarketNewsItem(
      id: 'news-005',
      title: 'Papa Blanca y Cebolla Roja: Nuevos estándares de clasificación y empaque agregan valor al productor local',
      summary:
          'Comerciantes y cadenas minoristas están premiando con mejores cotizaciones los lotes lavados, clasificados por calibre y en mallas respirables, reduciendo mermas de transporte hasta en un 18%.',
      commercialAnalysis:
          'Los lotes con valor agregado logran sobreprecios de hasta un 12% frente a la venta a granel tradicional. Fomenta la adopción de empaques modernos para acceder a compradores institucionales.',
      sourceName: 'InfoAgro Tendencias',
      sourceUrl: 'https://www.infoagro.com/',
      publishedAt: '22 sep. 2026',
      category: 'Vegetales',
      trend: MarketTrendType.up,
      trendImpact: 'Mayor valor agregado (+8.5%)',
      relatedProducts: ['Papa Blanca', 'Cebolla Roja', 'Tubérculos'],
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600',
      readTimeMinutes: 4,
    ),
    const MarketNewsItem(
      id: 'news-006',
      title: 'Cítricos y Limón Persa: Clima favorable favorece floración y anticipa excelente rendimiento estacional',
      summary:
          'Las precipitaciones regulares en las regiones citricolas aseguran calibres uniformes y alto contenido de jugo, lo que atraerá tanto a la industria de jugos como a los exportadores de fruta fresca.',
      commercialAnalysis:
          'Perspectiva de equilibrio entre oferta y demanda. Los precios tenderán a estabilizarse al comenzar el grueso del corte a mediados del próximo mes.',
      sourceName: 'AgroNoticias Latinoamérica',
      sourceUrl: 'https://www.portalfruticola.com/noticias/',
      publishedAt: '21 sep. 2026',
      category: 'Clima',
      trend: MarketTrendType.stable,
      trendImpact: 'Rendimiento óptimo (Estable)',
      relatedProducts: ['Limón Persa', 'Naranjas', 'Cítricos'],
      imageUrl: 'https://images.unsplash.com/photo-1536511135899-7f551817e089?w=600',
      readTimeMinutes: 3,
    ),
  ];

  List<MarketNewsItem> getAllNews() {
    return List.unmodifiable(_news);
  }

  List<MarketNewsItem> getNewsByCategory(String category) {
    if (category == 'Todas') return getAllNews();
    return _news.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<MarketNewsItem> searchNews(String query, {String category = 'Todas'}) {
    final baseList = getNewsByCategory(category);
    if (query.trim().isEmpty) return baseList;
    final q = query.trim().toLowerCase();
    return baseList.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q) ||
          item.sourceName.toLowerCase().contains(q) ||
          item.relatedProducts.any((prod) => prod.toLowerCase().contains(q));
    }).toList();
  }

  /// Retorna un resumen de señales y tendencias detectadas en el mercado a partir de las noticias
  Map<String, dynamic> getMarketTrendSignals() {
    int upCount = 0;
    int downCount = 0;
    int stableCount = 0;

    for (final item in _news) {
      switch (item.trend) {
        case MarketTrendType.up:
          upCount++;
          break;
        case MarketTrendType.down:
          downCount++;
          break;
        case MarketTrendType.stable:
          stableCount++;
          break;
      }
    }

    return {
      'totalNews': _news.length,
      'upTrends': upCount,
      'downTrends': downCount,
      'stableTrends': stableCount,
      'topMovingCrops': [
        {'crop': 'Aguacate Hass', 'direction': 'alza', 'tag': '+7.5%'},
        {'crop': 'Tomate Saladette', 'direction': 'baja', 'tag': '-6.0%'},
        {'crop': 'Plátano Verde', 'direction': 'alza', 'tag': '+4.0%'},
        {'crop': 'Papa Blanca', 'direction': 'alza', 'tag': '+8.5%'},
        {'crop': 'Arroz Selecto', 'direction': 'sin_cambios', 'tag': 'Sin cambios'},
        {'crop': 'Cebolla Roja', 'direction': 'sin_cambios', 'tag': 'Sin cambios'},
      ],
    };
  }

  /// Retorna la lista detallada de proyecciones predictivas por cultivo
  List<CropTrendPrediction> getCropTrendPredictions({String filter = 'Todos'}) {
    const list = [
      CropTrendPrediction(
        cropName: 'Aguacate Hass',
        category: 'Frutas',
        direction: 'alza',
        percentageTag: '+7.5%',
        forecastSummary:
            'Aumento sostenido de compras internacionales para exportación hacia Norteamérica y Europa presiona la oferta disponible y eleva cotizaciones en finca.',
        confidenceLevel: 'Alta',
        timeHorizon: 'Próximos 30 días',
        hasData: true,
        sourceName: 'Portal Frutícola',
        sourceUrl: 'https://www.portalfruticola.com/noticias/',
      ),
      CropTrendPrediction(
        cropName: 'Tomate Saladette',
        category: 'Vegetales',
        direction: 'baja',
        percentageTag: '-6.0%',
        forecastSummary:
            'Pico de cosecha simultáneo en valles bajo riego genera sobreoferta temporal y acumulación de cajas en mercados mayoristas centrales.',
        confidenceLevel: 'Alta',
        timeHorizon: 'Próximos 14 días',
        hasData: true,
        sourceName: 'FreshPlaza Agro',
        sourceUrl: 'https://www.freshplaza.es/',
      ),
      CropTrendPrediction(
        cropName: 'Plátano Verde',
        category: 'Víveres',
        direction: 'alza',
        percentageTag: '+4.0%',
        forecastSummary:
            'Fuerte dinamismo y alta rotación en comedores institucionales y restaurantes mantienen compras activas en centros de acopio.',
        confidenceLevel: 'Moderada',
        timeHorizon: 'Próximas 3 semanas',
        hasData: true,
        sourceName: 'Mercado Agro Central',
        sourceUrl: 'https://www.infoagro.com/',
      ),
      CropTrendPrediction(
        cropName: 'Papa Blanca',
        category: 'Tubérculos',
        direction: 'alza',
        percentageTag: '+8.5%',
        forecastSummary:
            'Nuevos estándares de lavado, clasificación por calibre y mallas respirables agregan valor y logran mejores cotizaciones en supermercados.',
        confidenceLevel: 'Moderada',
        timeHorizon: 'Próximos 20 días',
        hasData: true,
        sourceName: 'InfoAgro Tendencias',
        sourceUrl: 'https://www.infoagro.com/',
      ),
      CropTrendPrediction(
        cropName: 'Arroz Selecto',
        category: 'Granos',
        direction: 'sin_cambios',
        percentageTag: 'Sin cambios (±0.5%)',
        forecastSummary:
            'Inventarios nacionales estables y reservas de molineros garantizan abastecimiento continuo sin fluctuaciones abruptas.',
        confidenceLevel: 'Alta',
        timeHorizon: 'Próximos 60 días',
        hasData: true,
        sourceName: 'FAO Noticias Agropecuarias',
        sourceUrl: 'https://www.fao.org/newsroom/es',
      ),
      CropTrendPrediction(
        cropName: 'Limón Persa',
        category: 'Frutas',
        direction: 'sin_cambios',
        percentageTag: 'Sin cambios (Estable)',
        forecastSummary:
            'Precipitaciones equilibradas en cuencas citrícolas anticipan rendimiento óptimo que empata el ritmo de demanda exportadora.',
        confidenceLevel: 'Moderada',
        timeHorizon: 'Próximos 30 días',
        hasData: true,
        sourceName: 'AgroNoticias Latinoamérica',
        sourceUrl: 'https://www.portalfruticola.com/noticias/',
      ),
      CropTrendPrediction(
        cropName: 'Cebolla Roja Criolla',
        category: 'Vegetales',
        direction: 'sin_cambios',
        percentageTag: 'Sin cambios',
        forecastSummary:
            'Sin reportes de alteraciones climáticas ni cambios significativos de volumen en los centros mayoristas. Se mantiene sin variaciones estimadas.',
        confidenceLevel: 'En observación',
        timeHorizon: 'Período actual',
        hasData: false, // Sin datos para la tendencia
      ),
      CropTrendPrediction(
        cropName: 'Yuca Parafinada',
        category: 'Tubérculos',
        direction: 'sin_cambios',
        percentageTag: 'Sin cambios',
        forecastSummary:
            'No se identificaron noticias ni reportes de impacto reciente en los canales de comercialización agropecuaria. Sin cambios proyectados.',
        confidenceLevel: 'En observación',
        timeHorizon: 'Período actual',
        hasData: false, // Sin datos para la tendencia
      ),
      CropTrendPrediction(
        cropName: 'Zanahoria Criolla',
        category: 'Vegetales',
        direction: 'sin_cambios',
        percentageTag: 'Sin cambios',
        forecastSummary:
            'Sin datos suficientes registrados en el período evaluado para calcular una tendencia predictiva. Cotización de referencia sin cambios.',
        confidenceLevel: 'En observación',
        timeHorizon: 'Período actual',
        hasData: false, // Sin datos para la tendencia
      ),
    ];

    if (filter == 'Todos') return list;
    if (filter == 'Alza') return list.where((i) => i.direction == 'alza').toList();
    if (filter == 'Baja') return list.where((i) => i.direction == 'baja').toList();
    if (filter == 'Sin cambios') return list.where((i) => i.direction == 'sin_cambios').toList();
    return list;
  }

  /// Abre la URL de la publicación original en el navegador externo
  Future<bool> launchSourceUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final canOpen = await canLaunchUrl(uri);
      if (canOpen) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'No se pudo abrir el enlace: $url');
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error al abrir la fuente original: $e');
      }
      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
