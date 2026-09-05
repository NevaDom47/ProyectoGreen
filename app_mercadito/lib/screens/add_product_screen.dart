import 'package:flutter/material.dart';

class UnitPricingConfig {
  String unit;
  String saleType; // 'ambos', 'detalle', 'mayor'
  TextEditingController retailPriceCtrl;
  TextEditingController wholesalePriceCtrl;
  TextEditingController minWholesaleCtrl;
  TextEditingController maxWholesaleCtrl;
  bool isDefault;

  UnitPricingConfig({
    required this.unit,
    this.saleType = 'ambos',
    String retailPrice = '',
    String wholesalePrice = '',
    String minWholesale = '10',
    String maxWholesale = '100',
    this.isDefault = false,
  })  : retailPriceCtrl = TextEditingController(text: retailPrice),
        wholesalePriceCtrl = TextEditingController(text: wholesalePrice),
        minWholesaleCtrl = TextEditingController(text: minWholesale),
        maxWholesaleCtrl = TextEditingController(text: maxWholesale);

  void dispose() {
    retailPriceCtrl.dispose();
    wholesalePriceCtrl.dispose();
    minWholesaleCtrl.dispose();
    maxWholesaleCtrl.dispose();
  }

  Map<String, dynamic> toMap() {
    final double retail = double.tryParse(retailPriceCtrl.text.trim()) ?? 0.0;
    final double wholesale = double.tryParse(wholesalePriceCtrl.text.trim()) ?? 0.0;
    return {
      'unit': unit,
      'saleType': saleType,
      'priceRetail': retail,
      'priceWholesale': wholesale,
      'priceRetailStr': '\$${retail.toStringAsFixed(2)}',
      'priceWholesaleStr': '\$${wholesale.toStringAsFixed(2)}',
      'wholesaleMin': minWholesaleCtrl.text.trim(),
      'wholesaleMax': maxWholesaleCtrl.text.trim(),
      'isDefault': isDefault,
    };
  }
}

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;

  const AddProductScreen({
    super.key,
    this.initialProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Emerald Harvest Color Palette
  static const Color primaryColor = Color(0xFF00462F);
  static const Color primaryContainer = Color(0xFF036042);
  static const Color backgroundColor = Color(0xFFF7FAF5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF1F4F0);
  static const Color onSurface = Color(0xFF181D1A);
  static const Color onSurfaceVariant = Color(0xFF486456);
  static const Color outlineColor = Color(0x33BEC9C1);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Badge Tag Colors
  static const Color badgeRetailBg = Color(0xFF059669);
  static const Color badgeRetailText = Color(0xFFF1F9F7);
  static const Color badgeWholesaleBg = Color(0xFF0369A1);
  static const Color badgeWholesaleText = Color(0xFFEDF4F8);

  // Quality Tier Colors & Data
  static final List<Map<String, dynamic>> _qualityTiers = [
    {
      'id': 'Primera Calidad',
      'title': 'Primera Calidad',
      'subtitle': 'Máxima frescura, tamaño uniforme y selección premium.',
      'icon': Icons.workspace_premium,
      'badgeBg': const Color(0xFFDCE9E5),
      'badgeText': const Color(0xFF016042),
      'borderColor': const Color(0xFF016042),
    },
    {
      'id': 'Segunda Calidad',
      'title': 'Segunda Calidad',
      'subtitle': 'Buen sabor y frescura con ligeras variaciones de forma o tamaño.',
      'icon': Icons.workspace_premium,
      'badgeBg': const Color(0xFFFFF4E5),
      'badgeText': const Color(0xFFFF9A04),
      'borderColor': const Color(0xFFFF9A04),
    },
    {
      'id': 'Tercera Calidad',
      'title': 'Tercera Calidad',
      'subtitle': 'Estándar económico, ideal para procesamiento o uso comercial.',
      'icon': Icons.workspace_premium,
      'badgeBg': const Color(0xFFFDEDED),
      'badgeText': const Color(0xFFF44336),
      'borderColor': const Color(0xFFF44336),
    },
  ];

  // Units definitions and ordered list
  static const List<Map<String, String>> _unitDefinitions = [
    {'unit': 'LB', 'name': 'Libra', 'desc': 'Unidad de peso estándar (16 oz / 0.454 kg)'},
    {'unit': 'KG', 'name': 'Kilogramo', 'desc': 'Unidad de peso métrico (1.000 g / 2.2 LB)'},
    {'unit': 'Und', 'name': 'Unidad', 'desc': 'Pieza individual o fruto por unidad'},
    {'unit': 'Docena', 'name': 'Docena', 'desc': 'Conjunto de 12 unidades'},
    {'unit': 'Cto', 'name': 'Ciento', 'desc': 'Conjunto de 100 unidades de producto'},
    {'unit': 'Jarro', 'name': 'Jarro', 'desc': 'Medida tradicional por volumen o recipiente'},
    {'unit': 'Litro', 'name': 'Litro', 'desc': 'Unidad de volumen para líquidos o granos'},
    {'unit': 'Paq', 'name': 'Paquete', 'desc': 'Manojo, atado o bolsa empaquetada'},
    {'unit': 'Caja', 'name': 'Caja', 'desc': 'Contenedor estándar de transporte agrícola'},
    {'unit': 'Cubeta', 'name': 'Cubeta', 'desc': 'Recipiente o balde de cosecha'},
    {'unit': 'Saco', 'name': 'Saco', 'desc': 'Costal o saco grande para venta a granel'},
    {'unit': 'Mata', 'name': 'Mata', 'desc': 'Planta viva con raíz para trasplante/cosecha'},
    {'unit': 'QQ', 'name': 'Quintal', 'desc': 'Medida equivalente a 100 Libras'},
    {'unit': 'Bushel', 'name': 'Bushel', 'desc': 'Medida de volumen agrícola (~35.2 Litros)'},
    {'unit': 'Millar', 'name': 'Millar', 'desc': 'Conjunto de 1.000 unidades de producto'},
  ];

  static const List<String> _units = [
    'LB',
    'KG',
    'Und',
    'Docena',
    'Cto',
    'Jarro',
    'Litro',
    'Paq',
    'Caja',
    'Cubeta',
    'Saco',
    'Mata',
    'QQ',
    'Bushel',
    'Millar',
  ];

  final List<String> _categories = [
    'Hortalizas',
    'Frutas',
    'Cítricos',
    'Tubérculos',
    'Raíces',
    'Legumbres',
    'Granos',
    'Lácteos',
  ];

  // Preset Sample Images for quick selection
  final List<Map<String, String>> _sampleImages = [
    {
      'name': 'Tomates Frescos',
      'url':
          'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg'
    },
    {
      'name': 'Limón Colima',
      'url':
          'https://lh3.googleusercontent.com/aida/AEtjO1UDV4xCp1jhcb-egx-ZZs69cRSVWsKFPJbDs5xkG824bImlFddNkfuvUFIAC88rGP-Jp55kQWHiB6FW4SZ-rGaW3DRUqEb_HGtLYuz_FY2tPb8WIlbkWcpwzJ63EaoWFM7aHlX7Yo4NHJwGoOhgT8c5mYeCEQrxmB6-1sLYMwOHSJ45nrpaVqu_awDl5Mff3RLV2UrekFhLE5QIrW-yBLh86eqpu71Aolq3nXys9zWAHQ6cGCpwX9EecgI'
    },
    {
      'name': 'Aguacate Hass',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCx_eRxHSK6aT1dCBg3UZ21drqrz2a64dmGPr8oTG0AwxQg0tDHVh4AtgkqDL9nFU3WpSX7wpX-mqCzxe8EVd07TtoyRnGyMKSGzfqVdkh_j7V_WDyzIsqHtCn4ZTDR6b7aC1H3c0x9tVl_JkgdHXVc331TsEehHQuMybFAM2rM-_9QQlVy3Su13zKGeSWfPfrF5gFM-iyyAGPQc-_F_W34y3Acj64mtVxWzV11ufTeMWIzML5WRRVceAYqKkB1F4P_yYDKiV2M4QA'
    },
    {
      'name': 'Fresas de Campo',
      'url':
          'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png'
    },
    {
      'name': 'Papa Blanca Alpha',
      'url': 'assets/images/PapaGemini.png'
    },
    {
      'name': 'Zanahoria Orgánica',
      'url': 'assets/images/ZanahoriaGemini.png'
    },
    {
      'name': 'Pimientos Verdes',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCv3jV3L7cpRO9HHhAwc1zzNt0S_llbAIUGaXpbVaMB_U2jXRwE8hy8Sbt2hlP4U64bphnvVqdpf631X6lnfg_gpaDU1UlPGfs9je3le4DSo0PsI5sD262GoYyvYkXunxiURcx9rsUwtaI6qoVMlXL2XfCTnenvsfr1se3iUBH8BLZ5fzXRt1CHIPEn2CQNM8oNyQzjGoiJlp6vmiIvmRLkS8a7HvhE2baSdBU2XDKB_cKg3WSOADN8'
    },
  ];

  // Form Controllers & State
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Hortalizas';
  String _selectedQuality = 'Primera Calidad';

  // Multi-Unit Pricing Configurations (Max 4)
  final List<UnitPricingConfig> _unitConfigs = [];

  // Photos list
  late List<String> _photos;
  int _selectedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;

    _nameController = TextEditingController(text: p?['name'] ?? '');
    _skuController = TextEditingController(
      text: p?['sku'] ?? _generateSKU(p?['name'] ?? '', p?['category'] ?? 'Hortalizas'),
    );
    _descriptionController = TextEditingController(text: p?['description'] ?? '');

    _selectedCategory = p?['category'] ?? 'Hortalizas';
    _selectedQuality = p?['badge'] ?? 'Primera Calidad';

    // Initialize unit configurations
    if (p != null && p['unitConfigs'] != null && (p['unitConfigs'] as List).isNotEmpty) {
      final List rawConfigs = p['unitConfigs'] as List;
      for (int i = 0; i < rawConfigs.length && i < 4; i++) {
        final c = rawConfigs[i];
        _addUnitConfig(
          unit: c['unit'] ?? 'LB',
          saleType: c['saleType'] ?? 'ambos',
          retailPrice: c['priceRetail'] != null
              ? (c['priceRetail'] as num).toStringAsFixed(2)
              : (c['priceNum'] != null ? (c['priceNum'] as num).toStringAsFixed(2) : ''),
          wholesalePrice: c['priceWholesale'] != null
              ? (c['priceWholesale'] as num).toStringAsFixed(2)
              : (c['wholesalePriceNum'] != null ? (c['wholesalePriceNum'] as num).toStringAsFixed(2) : ''),
          minWholesale: c['wholesaleMin'] ?? '10',
          maxWholesale: c['wholesaleMax'] ?? '100',
          isDefault: c['isDefault'] ?? (i == 0),
        );
      }
    } else {
      // Default initial configuration
      final retail = p != null && p['priceNum'] != null ? (p['priceNum'] as num).toStringAsFixed(2) : '28.50';
      final wholesale = p != null && p['wholesalePriceNum'] != null ? (p['wholesalePriceNum'] as num).toStringAsFixed(2) : '22.00';
      final initialUnit = p?['unit'] ?? 'LB';
      final initialSaleType = p?['saleType'] ?? 'ambos';

      _addUnitConfig(
        unit: initialUnit,
        saleType: initialSaleType,
        retailPrice: retail,
        wholesalePrice: wholesale,
        minWholesale: '10',
        maxWholesale: '100',
        isDefault: true,
      );
    }

    if (p != null && p['img'] != null && p['img'].toString().isNotEmpty) {
      _photos = [p['img'].toString()];
    } else {
      _photos = [
        'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg'
      ];
    }

    _nameController.addListener(() => setState(() {}));
  }

  void _addUnitConfig({
    String unit = 'LB',
    String saleType = 'ambos',
    String retailPrice = '',
    String wholesalePrice = '',
    String minWholesale = '10',
    String maxWholesale = '100',
    bool isDefault = false,
  }) {
    if (_unitConfigs.length >= 4) return;

    final config = UnitPricingConfig(
      unit: unit,
      saleType: saleType,
      retailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      minWholesale: minWholesale,
      maxWholesale: maxWholesale,
      isDefault: isDefault || _unitConfigs.isEmpty,
    );

    config.retailPriceCtrl.addListener(() => setState(() {}));
    config.wholesalePriceCtrl.addListener(() => setState(() {}));
    config.minWholesaleCtrl.addListener(() => setState(() {}));
    config.maxWholesaleCtrl.addListener(() => setState(() {}));

    _unitConfigs.add(config);
  }

  void _setDefaultConfig(int index) {
    setState(() {
      for (int i = 0; i < _unitConfigs.length; i++) {
        _unitConfigs[i].isDefault = (i == index);
      }
    });
  }

  void _removeUnitConfig(int index) {
    if (_unitConfigs.length <= 1) return;
    setState(() {
      final wasDefault = _unitConfigs[index].isDefault;
      _unitConfigs[index].dispose();
      _unitConfigs.removeAt(index);
      if (wasDefault && _unitConfigs.isNotEmpty) {
        _unitConfigs[0].isDefault = true;
      }
    });
  }

  UnitPricingConfig get _defaultConfig {
    return _unitConfigs.firstWhere(
      (c) => c.isDefault,
      orElse: () => _unitConfigs.isNotEmpty ? _unitConfigs.first : UnitPricingConfig(unit: 'LB', isDefault: true),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    for (final c in _unitConfigs) {
      c.dispose();
    }
    super.dispose();
  }

  String _generateSKU(String name, String category) {
    final catCode = category.length >= 3 ? category.substring(0, 3).toUpperCase() : 'PRD';
    final nameClean = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final nameCode = nameClean.length >= 3 ? nameClean.substring(0, 3).toUpperCase() : 'GEN';
    final randomSuffix = (10 + (DateTime.now().millisecondsSinceEpoch % 89)).toString();
    return '$catCode-$nameCode-$randomSuffix';
  }

  void _showAddPhotoModal() {
    final urlCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: primaryColor, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Añadir Fotografía',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: onSurfaceVariant),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona una imagen de nuestro catálogo agrícola o ingresa una URL:',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Presets Grid
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sampleImages.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final item = _sampleImages[idx];
                          final isAsset = item['url']!.startsWith('assets/');
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (!_photos.contains(item['url'])) {
                                  _photos.add(item['url']!);
                                  _selectedPhotoIndex = _photos.length - 1;
                                }
                              });
                              Navigator.of(ctx).pop();
                            },
                            child: Container(
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineColor),
                                color: surfaceLow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                      child: isAsset
                                          ? Image.asset(
                                              item['url']!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: primaryColor),
                                            )
                                          : Image.network(
                                              item['url']!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: primaryColor),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: Text(
                                      item['name']!,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'O ingresa URL directa de la imagen:',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: urlCtrl,
                      decoration: InputDecoration(
                        hintText: 'https://ejemplo.com/foto_producto.jpg',
                        prefixIcon: const Icon(Icons.link, color: primaryColor),
                        filled: true,
                        fillColor: surfaceLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final text = urlCtrl.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              _photos.add(text);
                              _selectedPhotoIndex = _photos.length - 1;
                            });
                            Navigator.of(ctx).pop();
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(
                          'AGREGAR URL',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUnitsInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, size: 20, color: primaryColor),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Unidades de Medida',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Guía rápida de abreviaturas y definiciones:',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _unitDefinitions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: outlineColor),
                  itemBuilder: (context, idx) {
                    final item = _unitDefinitions[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 62,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: surfaceLow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              item['unit']!,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: '= ${item['name']!}: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: item['desc']!,
                                    style: const TextStyle(color: onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'ENTENDIDO',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Por favor completa todos los campos requeridos.'),
              ),
            ],
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Default primary unit config
    final def = _defaultConfig;
    final double retailVal = double.tryParse(def.retailPriceCtrl.text.trim()) ?? 0.0;
    final double wholesaleVal = double.tryParse(def.wholesalePriceCtrl.text.trim()) ?? (retailVal * 0.8);
    final double displayMainPrice = def.saleType == 'mayor' ? wholesaleVal : retailVal;

    final int stockVal = widget.initialProduct?['stock'] ?? 100;
    final int minAlertVal = widget.initialProduct?['minStockAlert'] ?? 10;

    final String mainImage = _photos.isNotEmpty
        ? _photos[_selectedPhotoIndex.clamp(0, _photos.length - 1)]
        : 'assets/images/PapaGemini.png';

    final unitConfigsList = _unitConfigs.map((c) => c.toMap()).toList();

    final productData = {
      'id': widget.initialProduct?['id'] ?? 'PROD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'badge': _selectedQuality,
      'saleType': def.saleType,
      'price': '\$${displayMainPrice.toStringAsFixed(2)}',
      'priceNum': displayMainPrice,
      'wholesalePrice': '\$${wholesaleVal.toStringAsFixed(2)}',
      'wholesalePriceNum': wholesaleVal,
      'wholesaleMin': def.minWholesaleCtrl.text.trim().isEmpty ? '10 ${def.unit}' : '${def.minWholesaleCtrl.text.trim()} ${def.unit}',
      'wholesaleMax': def.maxWholesaleCtrl.text.trim().isEmpty ? '100 ${def.unit}' : '${def.maxWholesaleCtrl.text.trim()} ${def.unit}',
      'unit': def.unit,
      'unitConfigs': unitConfigsList,
      'stock': stockVal,
      'minStockAlert': minAlertVal,
      'status': 'Disponible',
      'sku': _skuController.text.trim(),
      'description': _descriptionController.text.trim(),
      'origin': widget.initialProduct?['origin'] ?? 'Valle Agrícola Central',
      'createdAt': widget.initialProduct?['createdAt'] ?? '28 Ago 2026',
      'img': mainImage,
      'photos': _photos,
    };

    _showSuccessDialog(productData);
  }

  void _showSuccessDialog(Map<String, dynamic> productData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCE9E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.initialProduct != null ? '¡Producto Actualizado!' : '¡Producto Guardado!',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${productData['name']} ha sido guardado exitosamente con ${productData['unitConfigs']?.length ?? 1} presentación(es) de venta.',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(productData);
                },
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101915) : backgroundColor;
    final cardBg = isDark ? const Color(0xFF1A2420) : surfaceColor;

    final displayName = _nameController.text.trim().isEmpty ? 'Tomates Orgánicos' : _nameController.text.trim();

    // Default configuration for live preview
    final def = _defaultConfig;
    final displayRetail = def.retailPriceCtrl.text.trim().isEmpty ? '28.50' : def.retailPriceCtrl.text.trim();
    final displayWholesale = def.wholesalePriceCtrl.text.trim().isEmpty ? '22.00' : def.wholesalePriceCtrl.text.trim();
    final displayMin = def.minWholesaleCtrl.text.trim().isEmpty ? '10' : def.minWholesaleCtrl.text.trim();
    final displayMax = def.maxWholesaleCtrl.text.trim().isEmpty ? '100' : def.maxWholesaleCtrl.text.trim();
    final displayUnit = def.unit;
    final displaySaleType = def.saleType;

    final activePhoto = _photos.isNotEmpty
        ? _photos[_selectedPhotoIndex.clamp(0, _photos.length - 1)]
        : 'assets/images/PapaGemini.png';
    final isAsset = activePhoto.startsWith('assets/');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.initialProduct != null ? 'Editar Producto' : 'Agregar Producto',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: primaryColor),
            tooltip: 'Guardar Producto',
            onPressed: _saveProduct,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // ==========================================
                    // 1. REAL-TIME LIVE PREVIEW CARD
                    // ==========================================
                    _buildSectionHeader('Vista Previa en Tarjeta Principal', Icons.visibility_outlined),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                        border: Border.all(color: outlineColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preview Image Header
                          Stack(
                            children: [
                              Container(
                                height: 160,
                                width: double.infinity,
                                color: surfaceLow,
                                child: isAsset
                                    ? Image.asset(
                                        activePhoto,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.eco, size: 48, color: primaryColor),
                                        ),
                                      )
                                    : Image.network(
                                        activePhoto,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.eco, size: 48, color: primaryColor),
                                        ),
                                      ),
                              ),
                              // Quality badge pill
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _selectedQuality.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Default unit badge
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Principal: $displayUnit',
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Preview Details
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17,
                                              color: onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$_selectedCategory • $_selectedQuality',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Main Card Price (Retail or Wholesale depending on saleType)
                                        if (displaySaleType != 'mayor')
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                '\$$displayRetail',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 18,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '/ $displayUnit',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                '\$$displayWholesale',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 18,
                                                  color: Color(0xFF0369A1),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '/ $displayUnit',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),

                                        if (displaySaleType == 'ambos')
                                          Text(
                                            'Por Mayor: \$$displayWholesale (Mín. $displayMin • Máx. $displayMax $displayUnit)',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0369A1),
                                            ),
                                          )
                                        else if (displaySaleType == 'mayor')
                                          Text(
                                            'Rango: Mín. $displayMin • Máx. $displayMax $displayUnit',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Sale mode badges
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (displaySaleType == 'detalle' || displaySaleType == 'ambos')
                                      _buildPillBadge('Detalle', badgeRetailBg, badgeRetailText, Icons.shopping_bag_outlined),
                                    if (displaySaleType == 'mayor' || displaySaleType == 'ambos')
                                      _buildPillBadge('Por Mayor', badgeWholesaleBg, badgeWholesaleText, Icons.inventory_2_outlined),
                                    _buildPillBadge(_selectedCategory, surfaceLow, onSurfaceVariant, Icons.category_outlined),
                                  ],
                                ),
                                if (_unitConfigs.length > 1) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: surfaceLow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.touch_app_outlined, size: 14, color: primaryColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '+${_unitConfigs.length - 1} presentación(es) más disponibles al ver el detalle (${_unitConfigs.where((c) => !c.isDefault).map((c) => c.unit).join(', ')})',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // 2. FOTOGRAFÍAS STRIP
                    // ==========================================
                    _buildSectionHeader('Fotografías del Producto', Icons.photo_library_outlined),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Photo Dashed Button
                          GestureDetector(
                            onTap: _showAddPhotoModal,
                            child: Container(
                              width: 88,
                              height: 88,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: surfaceLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: primaryColor, size: 26),
                                  SizedBox(height: 4),
                                  Text(
                                    'AÑADIR',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Photos List
                          ...List.generate(_photos.length, (index) {
                            final photo = _photos[index];
                            final isSelected = _selectedPhotoIndex == index;
                            final isAssetPhoto = photo.startsWith('assets/');

                            return GestureDetector(
                              onTap: () => setState(() => _selectedPhotoIndex = index),
                              child: Container(
                                width: 88,
                                height: 88,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? primaryColor : outlineColor,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x0A000000), blurRadius: 4),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: isAssetPhoto
                                          ? Image.asset(
                                              photo,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                            )
                                          : Image.network(
                                              photo,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                            ),
                                    ),
                                    if (index == 0)
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'PRINCIPAL',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    if (_photos.length > 1)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _photos.removeAt(index);
                                              if (_selectedPhotoIndex >= _photos.length) {
                                                _selectedPhotoIndex = _photos.length - 1;
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 2),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: errorColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // 3. BENTO GRID: INFORMACIÓN BÁSICA
                    // ==========================================
                    _buildBentoCard(
                      title: 'Información Básica',
                      icon: Icons.info_outline,
                      cardBg: cardBg,
                      children: [
                        // Nombre
                        _buildFieldLabel('NOMBRE DEL PRODUCTO *'),
                        TextFormField(
                          controller: _nameController,
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                          decoration: _buildInputDecoration(
                            hintText: 'Ej. Tomates Saladette Orgánicos',
                            prefixIcon: Icons.shopping_basket_outlined,
                          ),
                          onChanged: (val) {
                            if (_skuController.text.isEmpty || _skuController.text.contains('-GEN-')) {
                              _skuController.text = _generateSKU(val, _selectedCategory);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Categoría y SKU
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('CATEGORÍA *'),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedCategory,
                                    decoration: _buildInputDecoration(),
                                    items: _categories.map((c) {
                                      return DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 13,
                                            color: onSurface,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedCategory = val;
                                          _skuController.text = _generateSKU(_nameController.text, val);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('SKU / CÓDIGO'),
                                  TextFormField(
                                    controller: _skuController,
                                    decoration: _buildInputDecoration(
                                      hintText: 'HOR-TOM-01',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.refresh, size: 18, color: primaryColor),
                                        tooltip: 'Regenerar SKU',
                                        onPressed: () {
                                          setState(() {
                                            _skuController.text = _generateSKU(_nameController.text, _selectedCategory);
                                          });
                                        },
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Descripción
                        _buildFieldLabel('DESCRIPCIÓN / VARIEDAD'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: _buildInputDecoration(
                            hintText: 'Detalles sobre cosecha, tamaño, sabor o empaque...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 4. BENTO GRID: PRECIOS Y UNIDADES DE MEDIDA (MULTI-CONFIG HASTA 4)
                    // ==========================================
                    _buildMultiUnitPricingSection(cardBg),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 5. SECCIÓN ESPECIAL: CALIDAD DEL PRODUCTO
                    // ==========================================
                    _buildSpecialQualitySection(cardBg),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 6. SECCIÓN EN DESARROLLO (COMING SOON): INVENTARIO, ORIGEN Y FRESCURA
                    // ==========================================
                    _buildComingSoonSection(cardBg),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ==========================================
              // STICKY BOTTOM ACTION BAR
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: const Border(
                    top: BorderSide(color: outlineColor, width: 1),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _saveProduct,
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      widget.initialProduct != null ? 'ACTUALIZAR PRODUCTO' : 'GUARDAR PRODUCTO',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Multi-Unit Pricing Section (Max 4 Units) ---
  Widget _buildMultiUnitPricingSection(Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_outlined, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precios y Unidades de Venta',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Configura hasta 4 unidades de medida para este producto',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineColor),
                ),
                child: Text(
                  '${_unitConfigs.length}/4',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Render each Unit Configuration Card
          ...List.generate(_unitConfigs.length, (idx) {
            final config = _unitConfigs[idx];
            return _buildSingleUnitConfigCard(config, idx, cardBg);
          }),

          // Button to Add another Unit (if < 4)
          if (_unitConfigs.length < 4) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor, style: BorderStyle.solid, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: primaryColor.withValues(alpha: 0.04),
                ),
                onPressed: () {
                  // Find next unused unit from _units list
                  final usedUnits = _unitConfigs.map((c) => c.unit).toSet();
                  final nextUnit = _units.firstWhere((u) => !usedUnits.contains(u), orElse: () => 'Caja');
                  setState(() {
                    _addUnitConfig(
                      unit: nextUnit,
                      saleType: 'ambos',
                      retailPrice: '',
                      wholesalePrice: '',
                      minWholesale: '10',
                      maxWholesale: '100',
                      isDefault: false,
                    );
                  });
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  'AÑADIR OTRA UNIDAD DE MEDIDA (${_unitConfigs.length}/4)',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Card for an individual Unit of Measure configuration
  Widget _buildSingleUnitConfigCard(UnitPricingConfig config, int index, Color cardBg) {
    final bool isDefault = config.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDefault ? primaryColor.withValues(alpha: 0.03) : surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefault ? primaryColor : outlineColor,
          width: isDefault ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Unit Number, Default Star, and Delete Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDefault ? primaryColor : onSurfaceVariant.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}. ${config.unit}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDefault ? Colors.white : onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Default Selector Chip / Button
              GestureDetector(
                onTap: () => _setDefaultConfig(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDefault ? const Color(0xFFFFF3CD) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDefault ? const Color(0xFFFFC107) : outlineColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDefault ? Icons.star : Icons.star_border,
                        size: 14,
                        color: isDefault ? const Color(0xFFD39E00) : onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDefault ? 'PREDETERMINADA (TARJETA)' : 'Hacer Predeterminada',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDefault ? const Color(0xFF856404) : onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_unitConfigs.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: errorColor, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Eliminar esta unidad',
                  onPressed: () => _removeUnitConfig(index),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Unit Selector Row with Info Dialog Button
          Row(
            children: [
              _buildFieldLabel('UNIDAD DE MEDIDA *'),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _showUnitsInfoDialog,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: primaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: config.unit,
            decoration: _buildInputDecoration(),
            items: _units.map((u) {
              return DropdownMenuItem(
                value: u,
                child: Text(
                  u,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  config.unit = val;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Sale Type Selector (Ambos / Al Detalle / Por Mayor)
          _buildFieldLabel('TIPO DE VENTA DISPONIBLE *'),
          Row(
            children: [
              _buildSaleTypeConfigOption(config, 'ambos', 'Ambos', Icons.all_inclusive),
              const SizedBox(width: 6),
              _buildSaleTypeConfigOption(config, 'detalle', 'Al Detalle', Icons.shopping_bag_outlined),
              const SizedBox(width: 6),
              _buildSaleTypeConfigOption(config, 'mayor', 'Por Mayor', Icons.inventory_2_outlined),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Pricing Fields based on selected saleType
          if (config.saleType == 'ambos') ...[
            // Ambos: Show both Retail and Wholesale prices
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('PRECIO AL DETALLE (\$) *'),
                      TextFormField(
                        controller: config.retailPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Requerido';
                          if (double.tryParse(val) == null) return 'Inválido';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hintText: '28.50',
                          prefixText: '\$ ',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('PRECIO POR MAYOR (\$) *'),
                      TextFormField(
                        controller: config.wholesalePriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Requerido';
                          if (double.tryParse(val) == null) return 'Inválido';
                          return null;
                        },
                        decoration: _buildInputDecoration(
                          hintText: '22.00',
                          prefixText: '\$ ',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Min and Max for wholesale
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('MÍNIMO POR MAYOR'),
                      TextFormField(
                        controller: config.minWholesaleCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: '10',
                          suffixText: config.unit,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('MÁXIMO POR MAYOR'),
                      TextFormField(
                        controller: config.maxWholesaleCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: '100',
                          suffixText: config.unit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else if (config.saleType == 'detalle') ...[
            // Al Detalle: Only Retail Price is visible
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('PRECIO AL DETALLE (\$) *'),
                TextFormField(
                  controller: config.retailPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Requerido';
                    if (double.tryParse(val) == null) return 'Inválido';
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hintText: '28.50',
                    prefixText: '\$ ',
                  ),
                ),
              ],
            ),
          ] else if (config.saleType == 'mayor') ...[
            // Por Mayor: Only Wholesale Price and Min/Max are visible
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('PRECIO POR MAYOR (\$) *'),
                TextFormField(
                  controller: config.wholesalePriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Requerido';
                    if (double.tryParse(val) == null) return 'Inválido';
                    return null;
                  },
                  decoration: _buildInputDecoration(
                    hintText: '22.00',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('MÍNIMO POR MAYOR'),
                          TextFormField(
                            controller: config.minWholesaleCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(
                              hintText: '10',
                              suffixText: config.unit,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('MÁXIMO POR MAYOR'),
                          TextFormField(
                            controller: config.maxWholesaleCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(
                              hintText: '100',
                              suffixText: config.unit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaleTypeConfigOption(UnitPricingConfig config, String value, String label, IconData icon) {
    final isSelected = config.saleType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => config.saleType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryColor : outlineColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Special Section for Product Quality Classification
  Widget _buildSpecialQualitySection(Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A00462F),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calidad del Producto',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Selecciona el estándar de clasificación agrícola',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quality Cards
          ...List.generate(_qualityTiers.length, (index) {
            final tier = _qualityTiers[index];
            final String tierId = tier['id'];
            final bool isSelected = _selectedQuality == tierId;
            final Color badgeBg = tier['badgeBg'];
            final Color badgeText = tier['badgeText'];
            final IconData tierIcon = tier['icon'];

            return GestureDetector(
              onTap: () => setState(() => _selectedQuality = tierId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? badgeBg.withValues(alpha: 0.35) : surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? badgeText : outlineColor,
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        tierIcon,
                        size: 22,
                        color: badgeText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tier['title'],
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: badgeText,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVO',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tier['subtitle'],
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: isSelected ? badgeText : const Color(0xFFB0BEC5),
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Coming Soon Section for Inventory, Origin & Freshness
  Widget _buildComingSoonSection(Color cardBg) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.55,
          child: AbsorbPointer(
            absorbing: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outlineColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Inventario, Origen y Frescura',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          initialValue: '100',
                          decoration: _buildInputDecoration(
                            hintText: 'Stock Actual',
                            prefixIcon: Icons.layers_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          initialValue: 'Valle Central',
                          decoration: _buildInputDecoration(
                            hintText: 'Finca / Ubicación',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: primaryColor),
                  SizedBox(width: 6),
                  Text(
                    'EN DESARROLLO (COMING SOON)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required IconData icon,
    required Color cardBg,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? prefixIcon,
    String? prefixText,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        color: Color(0xFF9E9E9E),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: onSurfaceVariant) : null,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.bold,
        fontSize: 11,
        color: primaryColor,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceLow,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.2),
      ),
    );
  }

  Widget _buildPillBadge(String label, Color bg, Color text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
