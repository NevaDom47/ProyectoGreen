import '../models/standard_catalog_product.dart';

class StandardProductCatalogService {
  StandardProductCatalogService._internal();
  static final StandardProductCatalogService instance = StandardProductCatalogService._internal();

  /// Catálogo oficial de productos agrícolas estandarizados de Mercadito.
  /// Contiene referencias de precios promedios del mercado para comparación en tiempo real.
  final List<StandardCatalogProduct> _catalog = const [
    StandardCatalogProduct(
      id: 'cat_tomate_saladette',
      name: 'Tomate Saladette',
      category: 'Hortalizas',
      defaultUnit: 'LB',
      skuPrefix: 'HOR-TOM',
      aliases: ['tomate', 'saladette', 'jitomate', 'tomates', 'tomate pera'],
      referenceRetailPrice: 28.50,
      referenceWholesalePrice: 22.00,
      description: 'Tomate alargado tipo pera, ideal para consumo en fresco y salsas.',
      sampleImage:
          'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg',
    ),
    StandardCatalogProduct(
      id: 'cat_tomate_bola',
      name: 'Tomate Bola',
      category: 'Hortalizas',
      defaultUnit: 'LB',
      skuPrefix: 'HOR-TBO',
      aliases: ['tomate bola', 'tomate redondo', 'tomate ensalada'],
      referenceRetailPrice: 35.00,
      referenceWholesalePrice: 28.00,
      description: 'Tomate redondo de gran calibre, ideal para ensaladas y rebanadas.',
    ),
    StandardCatalogProduct(
      id: 'cat_limon_colima',
      name: 'Limón Colima',
      category: 'Cítricos',
      defaultUnit: 'LB',
      skuPrefix: 'CIT-LIM',
      aliases: ['limon', 'limón', 'colima', 'limon con semilla', 'limon agrio'],
      referenceRetailPrice: 35.00,
      referenceWholesalePrice: 28.00,
      description: 'Limón mexicano agrio con semilla, alto rendimiento en jugo y aroma.',
      sampleImage:
          'https://lh3.googleusercontent.com/aida/AEtjO1UDV4xCp1jhcb-egx-ZZs69cRSVWsKFPJbDs5xkG824bImlFddNkfuvUFIAC88rGP-Jp55kQWHiB6FW4SZ-rGaW3DRUqEb_HGtLYuz_FY2tPb8WIlbkWcpwzJ63EaoWFM7aHlX7Yo4NHJwGoOhgT8c5mYeCEQrxmB6-1sLYMwOHSJ45nrpaVqu_awDl5Mff3RLV2UrekFhLE5QIrW-yBLh86eqpu71Aolq3nXys9zWAHQ6cGCpwX9EecgI',
    ),
    StandardCatalogProduct(
      id: 'cat_limon_persa',
      name: 'Limón Persa',
      category: 'Cítricos',
      defaultUnit: 'LB',
      skuPrefix: 'CIT-PER',
      aliases: ['limon persa', 'limon sin semilla', 'persa', 'tahiti'],
      referenceRetailPrice: 30.00,
      referenceWholesalePrice: 24.00,
      description: 'Limón verde sin semilla, tamaño grande y piel lisa.',
    ),
    StandardCatalogProduct(
      id: 'cat_aguacate_hass',
      name: 'Aguacate Hass',
      category: 'Frutas',
      defaultUnit: 'KG',
      skuPrefix: 'FRU-AGU',
      aliases: ['aguacate', 'hass', 'palta', 'palta hass', 'avocado'],
      referenceRetailPrice: 72.00,
      referenceWholesalePrice: 58.00,
      description: 'Aguacate cremoso de piel rugosa oscura, estándar internacional de exportación.',
      sampleImage:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCx_eRxHSK6aT1dCBg3UZ21drqrz2a64dmGPr8oTG0AwxQg0tDHVh4AtgkqDL9nFU3WpSX7wpX-mqCzxe8EVd07TtoyRnGyMKSGzfqVdkh_j7V_WDyzIsqHtCn4ZTDR6b7aC1H3c0x9tVl_JkgdHXVc331TsEehHQuMybFAM2rM-_9QQlVy3Su13zKGeSWfPfrF5gFM-iyyAGPQc-_F_W34y3Acj64mtVxWzV11ufTeMWIzML5WRRVceAYqKkB1F4P_yYDKiV2M4QA',
    ),
    StandardCatalogProduct(
      id: 'cat_aguacate_criollo',
      name: 'Aguacate Criollo',
      category: 'Frutas',
      defaultUnit: 'Und',
      skuPrefix: 'FRU-CRI',
      aliases: ['aguacate criollo', 'aguacate injerto', 'aguacate nativo'],
      referenceRetailPrice: 45.00,
      referenceWholesalePrice: 35.00,
      description: 'Aguacate criollo de piel lisa y pulpa suave con sabor tradicional.',
    ),
    StandardCatalogProduct(
      id: 'cat_papa_blanca_alpha',
      name: 'Papa Blanca Alpha',
      category: 'Tubérculos',
      defaultUnit: 'KG',
      skuPrefix: 'TUB-PAP',
      aliases: ['papa', 'papa blanca', 'patata', 'papa alpha', 'papas'],
      referenceRetailPrice: 22.50,
      referenceWholesalePrice: 18.00,
      description: 'Papa de piel clara y consistencia firme, óptima para freír y cocer.',
      sampleImage: 'assets/images/PapaGemini.png',
    ),
    StandardCatalogProduct(
      id: 'cat_papa_criolla',
      name: 'Papa Criolla Amarilla',
      category: 'Tubérculos',
      defaultUnit: 'KG',
      skuPrefix: 'TUB-AMA',
      aliases: ['papa amarilla', 'papa criolla', 'papa chola'],
      referenceRetailPrice: 28.00,
      referenceWholesalePrice: 22.00,
      description: 'Papa pequeña amarilla de cocción rápida y textura harinosa gourmet.',
    ),
    StandardCatalogProduct(
      id: 'cat_zanahoria_organica',
      name: 'Zanahoria Orgánica',
      category: 'Raíces',
      defaultUnit: 'KG',
      skuPrefix: 'RAI-ZAN',
      aliases: ['zanahoria', 'zanahorias', 'carrot'],
      referenceRetailPrice: 15.00,
      referenceWholesalePrice: 11.00,
      description: 'Zanahoria fresca de raíz dulce, rica en betacarotenos y color intenso.',
      sampleImage: 'assets/images/ZanahoriaGemini.png',
    ),
    StandardCatalogProduct(
      id: 'cat_fresas_campo',
      name: 'Fresas de Campo',
      category: 'Frutas',
      defaultUnit: 'KG',
      skuPrefix: 'FRU-FRE',
      aliases: ['fresa', 'fresas', 'frutilla', 'strawberry'],
      referenceRetailPrice: 48.00,
      referenceWholesalePrice: 38.00,
      description: 'Fresas frescas de montaña cosechadas a mano en su punto óptimo de dulzura.',
      sampleImage:
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png',
    ),
    StandardCatalogProduct(
      id: 'cat_cebolla_roja',
      name: 'Cebolla Roja',
      category: 'Hortalizas',
      defaultUnit: 'LB',
      skuPrefix: 'HOR-CEB',
      aliases: ['cebolla', 'cebolla morada', 'cebolla roja', 'onion'],
      referenceRetailPrice: 32.00,
      referenceWholesalePrice: 25.00,
      description: 'Cebolla de bulbo morado intenso, aromática y crocante.',
    ),
    StandardCatalogProduct(
      id: 'cat_cebolla_blanca',
      name: 'Cebolla Blanca',
      category: 'Hortalizas',
      defaultUnit: 'LB',
      skuPrefix: 'HOR-CBL',
      aliases: ['cebolla blanca', 'cebolla dulce'],
      referenceRetailPrice: 28.00,
      referenceWholesalePrice: 22.00,
      description: 'Cebolla blanca de sabor suave para todo uso culinario.',
    ),
    StandardCatalogProduct(
      id: 'cat_arroz_campo',
      name: 'Arroz Campo Selecto',
      category: 'Granos',
      defaultUnit: 'LB',
      skuPrefix: 'GRA-ARR',
      aliases: ['arroz', 'arroz blanco', 'arroz selecto', 'rice'],
      referenceRetailPrice: 24.00,
      referenceWholesalePrice: 19.50,
      description: 'Arroz de grano largo seleccionado de molienda fresca.',
    ),
    StandardCatalogProduct(
      id: 'cat_frijol_negro',
      name: 'Frijol Negro',
      category: 'Granos',
      defaultUnit: 'LB',
      skuPrefix: 'GRA-FNE',
      aliases: ['frijol', 'frijol negro', 'habichuela negra', 'beans'],
      referenceRetailPrice: 40.00,
      referenceWholesalePrice: 32.00,
      description: 'Frijol negro brillante, rico en hierro y rápida cocción.',
    ),
    StandardCatalogProduct(
      id: 'cat_frijol_flor_mayo',
      name: 'Frijol Flor de Mayo',
      category: 'Granos',
      defaultUnit: 'LB',
      skuPrefix: 'GRA-FFM',
      aliases: ['frijol pinto', 'flor de mayo', 'frijol moteado'],
      referenceRetailPrice: 45.00,
      referenceWholesalePrice: 36.00,
      description: 'Frijol cremoso moteado tradicional para guisos y sopas.',
    ),
    StandardCatalogProduct(
      id: 'cat_maiz_blanco',
      name: 'Maíz Blanco',
      category: 'Granos',
      defaultUnit: 'LB',
      skuPrefix: 'GRA-MAI',
      aliases: ['maiz', 'maíz', 'choclo', 'corn'],
      referenceRetailPrice: 18.00,
      referenceWholesalePrice: 14.50,
      description: 'Maíz desgranado seco para molienda, harinas y forraje.',
    ),
    StandardCatalogProduct(
      id: 'cat_platano_verde',
      name: 'Plátano Verde',
      category: 'Frutas',
      defaultUnit: 'Und',
      skuPrefix: 'FRU-PLV',
      aliases: ['platano', 'plátano', 'platano verde', 'platanos'],
      referenceRetailPrice: 18.00,
      referenceWholesalePrice: 14.00,
      description: 'Plátano macho verde criollo para tostones, mangú y hervido.',
    ),
    StandardCatalogProduct(
      id: 'cat_platano_maduro',
      name: 'Plátano Maduro',
      category: 'Frutas',
      defaultUnit: 'Und',
      skuPrefix: 'FRU-PLM',
      aliases: ['platano maduro', 'maduro'],
      referenceRetailPrice: 20.00,
      referenceWholesalePrice: 15.50,
      description: 'Plátano maduro dulce y carnoso para fritura y horneado.',
    ),
    StandardCatalogProduct(
      id: 'cat_yuca_mocana',
      name: 'Yuca Mocana',
      category: 'Raíces',
      defaultUnit: 'LB',
      skuPrefix: 'RAI-YUC',
      aliases: ['yuca', 'mandioca', 'yuca mocana', 'cassava'],
      referenceRetailPrice: 20.00,
      referenceWholesalePrice: 15.00,
      description: 'Yuca parafina blanca de rápida cocción suave y mantecosa.',
    ),
    StandardCatalogProduct(
      id: 'cat_batata_dulce',
      name: 'Batata Dulce',
      category: 'Tubérculos',
      defaultUnit: 'LB',
      skuPrefix: 'TUB-BAT',
      aliases: ['batata', 'camote', 'boniato', 'sweet potato'],
      referenceRetailPrice: 18.00,
      referenceWholesalePrice: 14.00,
      description: 'Batata dulce morada con pulpa blanca azucarada.',
    ),
    StandardCatalogProduct(
      id: 'cat_lechuga_romana',
      name: 'Lechuga Romana',
      category: 'Hortalizas',
      defaultUnit: 'Und',
      skuPrefix: 'HOR-LEC',
      aliases: ['lechuga', 'lechuga romana', 'lettuce'],
      referenceRetailPrice: 25.00,
      referenceWholesalePrice: 18.00,
      description: 'Lechuga de cogollo erguido, hojas crujientes hidropónicas.',
    ),
    StandardCatalogProduct(
      id: 'cat_pimiento_morron',
      name: 'Pimiento Morrón Verde',
      category: 'Hortalizas',
      defaultUnit: 'LB',
      skuPrefix: 'HOR-PIM',
      aliases: ['pimiento', 'morron', 'aji morron', 'chile morron', 'bell pepper'],
      referenceRetailPrice: 35.00,
      referenceWholesalePrice: 27.00,
      description: 'Ají morrón verde de cuatro lóbulos con paredes gruesas y carnosas.',
    ),
    StandardCatalogProduct(
      id: 'cat_habichuelas_rojas',
      name: 'Habichuelas Rojas',
      category: 'Legumbres',
      defaultUnit: 'LB',
      skuPrefix: 'LEG-HAB',
      aliases: ['habichuela', 'habichuelas rojas', 'frijol rojo', 'kidney beans'],
      referenceRetailPrice: 55.00,
      referenceWholesalePrice: 45.00,
      description: 'Habichuela roja dominicana de grano uniforme sin impurezas.',
    ),
    StandardCatalogProduct(
      id: 'cat_guandules_verdes',
      name: 'Guandules Verdes',
      category: 'Legumbres',
      defaultUnit: 'LB',
      skuPrefix: 'LEG-GUA',
      aliases: ['guandules', 'gandules', 'pigeon peas'],
      referenceRetailPrice: 65.00,
      referenceWholesalePrice: 50.00,
      description: 'Guandul verde fresco desvainado listo para cocinar.',
    ),
    StandardCatalogProduct(
      id: 'cat_mango_banilejo',
      name: 'Mango Banilejo',
      category: 'Frutas',
      defaultUnit: 'Docena',
      skuPrefix: 'FRU-MAN',
      aliases: ['mango', 'mango banilejo', 'manga'],
      referenceRetailPrice: 40.00,
      referenceWholesalePrice: 30.00,
      description: 'Mango aromático de Baní, pulpa amarilla intensa sin hilachas.',
    ),
    StandardCatalogProduct(
      id: 'cat_pina_cayena',
      name: 'Piña Pan de Azúcar / Cayena',
      category: 'Frutas',
      defaultUnit: 'Und',
      skuPrefix: 'FRU-PIN',
      aliases: ['pina', 'piña', 'pineapple'],
      referenceRetailPrice: 60.00,
      referenceWholesalePrice: 45.00,
      description: 'Piña dulce de pulpa jugosa con bajo contenido de acidez.',
    ),
    StandardCatalogProduct(
      id: 'cat_queso_criollo',
      name: 'Queso Criollo de Finca',
      category: 'Lácteos',
      defaultUnit: 'LB',
      skuPrefix: 'LAC-QUE',
      aliases: ['queso', 'queso criollo', 'queso blanco', 'cheese'],
      referenceRetailPrice: 180.00,
      referenceWholesalePrice: 150.00,
      description: 'Queso artesanal de leche pura entera de vaca, ideal para freír.',
    ),
    StandardCatalogProduct(
      id: 'cat_leche_fresca',
      name: 'Leche Fresca Pasteurizada',
      category: 'Lácteos',
      defaultUnit: 'Litro',
      skuPrefix: 'LAC-LEC',
      aliases: ['leche', 'leche fresca', 'milk'],
      referenceRetailPrice: 65.00,
      referenceWholesalePrice: 52.00,
      description: 'Leche de vaca grado A 100% natural sin aditivos.',
    ),
  ];

  /// Devuelve todo el catálogo de productos disponibles
  List<StandardCatalogProduct> get allProducts => List.unmodifiable(_catalog);

  /// Normaliza una cadena para búsquedas eliminando tildes y mayúsculas
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .trim();
  }

  /// Filtra productos en tiempo real según el texto escrito por el usuario
  List<StandardCatalogProduct> searchProducts(String query, {String? category}) {
    final cleanQuery = _normalize(query);

    return _catalog.where((product) {
      if (category != null && category.isNotEmpty && category != 'Todas' && category != 'Todos') {
        if (_normalize(product.category) != _normalize(category)) {
          return false;
        }
      }

      if (cleanQuery.isEmpty) return true;

      // Coincidencia con nombre principal
      if (_normalize(product.name).contains(cleanQuery)) {
        return true;
      }

      // Coincidencia con categoría
      if (_normalize(product.category).contains(cleanQuery)) {
        return true;
      }

      // Coincidencia con alias
      for (final alias in product.aliases) {
        if (_normalize(alias).contains(cleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  /// Verifica si el nombre ingresado corresponde de forma obligatoria a un producto del catálogo oficial
  bool isValidProductName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final normalized = _normalize(name);
    return _catalog.any((p) => _normalize(p.name) == normalized);
  }

  /// Encuentra el producto estándar exacto por su nombre o alias principal
  StandardCatalogProduct? findProductByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final normalized = _normalize(name);

    // 1. Coincidencia exacta con nombre
    for (final p in _catalog) {
      if (_normalize(p.name) == normalized) return p;
    }

    // 2. Coincidencia con alias
    for (final p in _catalog) {
      for (final a in p.aliases) {
        if (_normalize(a) == normalized) return p;
      }
    }

    // 3. Coincidencia parcial si contiene el nombre
    for (final p in _catalog) {
      if (_normalize(p.name).contains(normalized) || normalized.contains(_normalize(p.name))) {
        return p;
      }
    }

    return null;
  }

  /// Evalúa el precio para un nombre de producto y devuelve el análisis de mercado
  PriceEvaluation? evaluatePrice(String productName, double price, {bool isWholesale = false}) {
    final product = findProductByName(productName);
    if (product == null) return null;
    return product.evaluatePrice(price, isWholesale: isWholesale);
  }
}
