import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnitPricingConfig {
  String unit;
  String saleType; // 'detalle' or 'mayor'
  TextEditingController retailPriceCtrl;
  TextEditingController wholesalePriceCtrl;
  TextEditingController minWholesaleCtrl;
  TextEditingController maxWholesaleCtrl;
  bool isDefault;

  UnitPricingConfig({
    required this.unit,
    this.saleType = 'detalle',
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
    final bool isRetail = saleType == 'detalle';
    return {
      'unit': unit,
      'saleType': saleType,
      'priceRetail': isRetail ? retail : 0.0,
      'priceWholesale': !isRetail ? wholesale : 0.0,
      'priceRetailStr': isRetail ? '\$${retail.toStringAsFixed(2)}' : '',
      'priceWholesaleStr': !isRetail ? '\$${wholesale.toStringAsFixed(2)}' : '',
      'wholesaleMin': !isRetail ? (minWholesaleCtrl.text.trim().isEmpty ? '10' : minWholesaleCtrl.text.trim()) : '',
      'wholesaleMax': !isRetail ? (maxWholesaleCtrl.text.trim().isEmpty ? '100' : maxWholesaleCtrl.text.trim()) : '',
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
  static const Color backgroundColor = Color(0xFFF7FAF5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF1F4F0);
  static const Color onSurface = Color(0xFF181D1A);
  static const Color onSurfaceVariant = Color(0xFF486456);
  static const Color outlineColor = Color(0x33BEC9C1);
  static const Color errorColor = Color(0xFFBA1A1A);

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

  // Preset Sample Videos for demonstration
  final List<Map<String, String>> _sampleVideos = [
    {
      'name': 'Video Cosecha de Campo (Demo)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '0:15 min',
    },
    {
      'name': 'Video Empaque y Calidad (Demo)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'duration': '0:15 min',
    },
  ];

  // Form Controllers & State
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Hortalizas';
  String _selectedQuality = 'Primera Calidad';

  // Independent Multi-Unit Pricing Configurations (Up to 4 Detalle + Up to 4 Mayor)
  final List<UnitPricingConfig> _retailConfigs = [];
  final List<UnitPricingConfig> _wholesaleConfigs = [];
  String _activePricingTab = 'detalle'; // 'detalle' o 'mayor'
  bool _enableRetail = true;
  bool _enableWholesale = true;

  // Top Input Form state for adding Retail Units
  String _newRetailUnit = 'Und';
  final TextEditingController _newRetailPriceCtrl = TextEditingController();

  // Top Input Form state for adding Wholesale Units
  String _newWholesaleUnit = 'Caja';
  final TextEditingController _newWholesalePriceCtrl = TextEditingController();
  final TextEditingController _newWholesaleMinCtrl = TextEditingController(text: '10');
  final TextEditingController _newWholesaleMaxCtrl = TextEditingController(text: '100');
  bool _newWholesaleUnlimited = false;

  // Available units filtered to avoid duplicates within each forma de venta
  List<String> get _availableRetailUnits {
    final used = _retailConfigs.map((c) => c.unit).toSet();
    return _units.where((u) => !used.contains(u)).toList();
  }

  List<String> get _availableWholesaleUnits {
    final used = _wholesaleConfigs.map((c) => c.unit).toSet();
    return _units.where((u) => !used.contains(u)).toList();
  }

  void _updateInitialNewUnits() {
    final availRetail = _availableRetailUnits;
    if (availRetail.isNotEmpty && !availRetail.contains(_newRetailUnit)) {
      _newRetailUnit = availRetail.first;
    }
    final availWholesale = _availableWholesaleUnits;
    if (availWholesale.isNotEmpty && !availWholesale.contains(_newWholesaleUnit)) {
      _newWholesaleUnit = availWholesale.first;
    }
  }

  // Media state (Up to 8 photos + strictly 1 pinned video)
  late List<String> _photos;
  String? _videoUrl;
  int _selectedPhotoIndex = 0;
  String _previewMode = 'detalle'; // 'detalle' o 'mayor'

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
      for (int i = 0; i < rawConfigs.length; i++) {
        final c = rawConfigs[i];
        final type = (c['saleType'] ?? 'ambos').toString().toLowerCase();

        final String unit = c['unit'] ?? 'Und';
        final String retPrice = c['priceRetail'] != null
            ? (c['priceRetail'] as num).toStringAsFixed(2)
            : (c['priceNum'] != null ? (c['priceNum'] as num).toStringAsFixed(2) : '');
        final String whlPrice = c['priceWholesale'] != null
            ? (c['priceWholesale'] as num).toStringAsFixed(2)
            : (c['wholesalePriceNum'] != null ? (c['wholesalePriceNum'] as num).toStringAsFixed(2) : '');
        final String minWhl = c['wholesaleMin']?.toString() ?? '10';
        final String maxWhl = c['wholesaleMax']?.toString() ?? '100';
        final bool isDef = c['isDefault'] ?? false;

        if (type == 'detalle') {
          if (_retailConfigs.length < 4) {
            _addRetailConfig(
              unit: unit,
              retailPrice: retPrice.isNotEmpty ? retPrice : '28.50',
              isDefault: isDef || _retailConfigs.isEmpty,
            );
          }
        } else if (type == 'mayor') {
          if (_wholesaleConfigs.length < 4) {
            _addWholesaleConfig(
              unit: unit,
              wholesalePrice: whlPrice.isNotEmpty ? whlPrice : '22.00',
              minWholesale: minWhl,
              maxWholesale: maxWhl,
              isDefault: isDef || _wholesaleConfigs.isEmpty,
            );
          }
        } else {
          // 'ambos' legacy: split into both retail and wholesale configs
          if (_retailConfigs.length < 4) {
            _addRetailConfig(
              unit: unit,
              retailPrice: retPrice.isNotEmpty ? retPrice : '28.50',
              isDefault: isDef || _retailConfigs.isEmpty,
            );
          }
          if (_wholesaleConfigs.length < 4) {
            _addWholesaleConfig(
              unit: unit,
              wholesalePrice: whlPrice.isNotEmpty ? whlPrice : '22.00',
              minWholesale: minWhl,
              maxWholesale: maxWhl,
              isDefault: isDef || _wholesaleConfigs.isEmpty,
            );
          }
        }
      }
    } else {
      // Default initial configuration
      final retail = p != null && p['priceNum'] != null ? (p['priceNum'] as num).toStringAsFixed(2) : '28.50';
      final wholesale = p != null && p['wholesalePriceNum'] != null ? (p['wholesalePriceNum'] as num).toStringAsFixed(2) : '22.00';
      final initialUnit = p?['unit'] ?? 'Und';
      final pSaleType = (p?['saleType'] ?? 'ambos').toString().toLowerCase();

      if (pSaleType != 'mayor') {
        _addRetailConfig(
          unit: initialUnit,
          retailPrice: retail,
          isDefault: true,
        );
      }
      if (pSaleType != 'detalle') {
        _addWholesaleConfig(
          unit: initialUnit == 'Und' ? 'Caja' : initialUnit,
          wholesalePrice: wholesale,
          minWholesale: '10',
          maxWholesale: '100',
          isDefault: true,
        );
      }
    }

    _enableRetail = _retailConfigs.isNotEmpty;
    _enableWholesale = _wholesaleConfigs.isNotEmpty;
    if (!_enableRetail && _enableWholesale) {
      _activePricingTab = 'mayor';
      _previewMode = 'mayor';
    } else {
      _activePricingTab = 'detalle';
      _previewMode = 'detalle';
    }

    _updateInitialNewUnits();

    _videoUrl = p?['video']?.toString() ?? p?['videoUrl']?.toString();

    if (p != null && p['photos'] is List && (p['photos'] as List).isNotEmpty) {
      _photos = (p['photos'] as List).map((e) => e.toString()).take(8).toList();
    } else if (p != null && p['img'] != null && p['img'].toString().isNotEmpty) {
      _photos = [p['img'].toString()];
    } else {
      _photos = [
        'https://lh3.googleusercontent.com/aida/AEtjO1WJPFi5I7ZN-mHEOmgqdgmYQxGUivEKgUceqV8OcdNcWwowkcPmSiJrAgNG82XtSgoX-uePPMYN8BGd4CqtyuTb_DWJcL1N9EY-Zb9pw67Sxhks3OGyC9hadvAaJOIk0gudu0Hrum9DHf9E_MsgiO4Vq3RUl5yWwKlvGxQyVEZbHKV44heVYLB-SuP2c9B2EN7Wg5gaYaoj991-EEiBhW8g_oE8djsBWnAcvDzTbTF6XMHOPxANhCnCOzg'
      ];
    }

    _nameController.addListener(() => setState(() {}));
  }

  void _addRetailConfig({
    String unit = 'Und',
    String retailPrice = '',
    bool isDefault = false,
  }) {
    if (_retailConfigs.length >= 4) return;
    final config = UnitPricingConfig(
      unit: unit,
      saleType: 'detalle',
      retailPrice: retailPrice,
      isDefault: isDefault || _retailConfigs.isEmpty,
    );
    config.retailPriceCtrl.addListener(() => setState(() {}));
    _retailConfigs.add(config);
  }

  void _setRetailDefault(int index) {
    setState(() {
      for (int i = 0; i < _retailConfigs.length; i++) {
        _retailConfigs[i].isDefault = (i == index);
      }
    });
  }

  void _removeRetailConfig(int index) {
    if (_retailConfigs.length <= 1 && !_enableWholesale) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes mantener al menos una unidad configurada si la venta al por mayor está inactiva.'),
          backgroundColor: const Color(0xFFC05621),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() {
      final wasDefault = _retailConfigs[index].isDefault;
      _retailConfigs[index].dispose();
      _retailConfigs.removeAt(index);
      if (wasDefault && _retailConfigs.isNotEmpty) {
        _retailConfigs[0].isDefault = true;
      }
      _updateInitialNewUnits();
    });
  }

  void _submitNewRetailUnit() {
    if (_retailConfigs.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Has alcanzado el límite máximo de 4 unidades al detalle.'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final price = _newRetailPriceCtrl.text.trim();
    if (price.isEmpty || double.tryParse(price) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa un precio válido al detalle.'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_availableRetailUnits.isEmpty) return;

    setState(() {
      _addRetailConfig(
        unit: _newRetailUnit,
        retailPrice: price,
        isDefault: _retailConfigs.isEmpty,
      );
      _newRetailPriceCtrl.clear();
      _updateInitialNewUnits();
    });
  }

  void _addWholesaleConfig({
    String unit = 'Caja',
    String wholesalePrice = '',
    String minWholesale = '10',
    String maxWholesale = '100',
    bool isDefault = false,
  }) {
    if (_wholesaleConfigs.length >= 4) return;
    final config = UnitPricingConfig(
      unit: unit,
      saleType: 'mayor',
      wholesalePrice: wholesalePrice,
      minWholesale: minWholesale,
      maxWholesale: maxWholesale,
      isDefault: isDefault || _wholesaleConfigs.isEmpty,
    );
    config.wholesalePriceCtrl.addListener(() => setState(() {}));
    config.minWholesaleCtrl.addListener(() => setState(() {}));
    config.maxWholesaleCtrl.addListener(() => setState(() {}));
    _wholesaleConfigs.add(config);
  }

  void _setWholesaleDefault(int index) {
    setState(() {
      for (int i = 0; i < _wholesaleConfigs.length; i++) {
        _wholesaleConfigs[i].isDefault = (i == index);
      }
    });
  }

  void _removeWholesaleConfig(int index) {
    if (_wholesaleConfigs.length <= 1 && !_enableRetail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes mantener al menos una unidad configurada si la venta al detalle está inactiva.'),
          backgroundColor: const Color(0xFFC05621),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() {
      final wasDefault = _wholesaleConfigs[index].isDefault;
      _wholesaleConfigs[index].dispose();
      _wholesaleConfigs.removeAt(index);
      if (wasDefault && _wholesaleConfigs.isNotEmpty) {
        _wholesaleConfigs[0].isDefault = true;
      }
      _updateInitialNewUnits();
    });
  }

  void _submitNewWholesaleUnit() {
    if (_wholesaleConfigs.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Has alcanzado el límite máximo de 4 unidades al por mayor.'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final price = _newWholesalePriceCtrl.text.trim();
    if (price.isEmpty || double.tryParse(price) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa un precio válido al por mayor.'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final min = _newWholesaleMinCtrl.text.trim().isEmpty ? '10' : _newWholesaleMinCtrl.text.trim();
    final max = _newWholesaleUnlimited
        ? 'Sin límites'
        : (_newWholesaleMaxCtrl.text.trim().isEmpty ? 'Sin límites' : _newWholesaleMaxCtrl.text.trim());
    if (_availableWholesaleUnits.isEmpty) return;

    setState(() {
      _addWholesaleConfig(
        unit: _newWholesaleUnit,
        wholesalePrice: price,
        minWholesale: min,
        maxWholesale: max,
        isDefault: _wholesaleConfigs.isEmpty,
      );
      _newWholesalePriceCtrl.clear();
      _newWholesaleUnlimited = false;
      _newWholesaleMaxCtrl.text = '100';
      _updateInitialNewUnits();
    });
  }

  UnitPricingConfig? get _defaultRetailConfig {
    if (_retailConfigs.isEmpty) return null;
    return _retailConfigs.firstWhere((c) => c.isDefault, orElse: () => _retailConfigs.first);
  }

  UnitPricingConfig? get _defaultWholesaleConfig {
    if (_wholesaleConfigs.isEmpty) return null;
    return _wholesaleConfigs.firstWhere((c) => c.isDefault, orElse: () => _wholesaleConfigs.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _newRetailPriceCtrl.dispose();
    _newWholesalePriceCtrl.dispose();
    _newWholesaleMinCtrl.dispose();
    _newWholesaleMaxCtrl.dispose();
    for (final c in _retailConfigs) {
      c.dispose();
    }
    for (final c in _wholesaleConfigs) {
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

  // ===========================================================================
  // GESTIÓN DE FOTOGRAFÍAS Y VIDEO
  // ===========================================================================

  void _setMainPhoto(int index) {
    if (index <= 0 || index >= _photos.length) return;
    setState(() {
      final photo = _photos.removeAt(index);
      _photos.insert(0, photo);
      _selectedPhotoIndex = 0;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Foto establecida como Imagen Principal del producto.',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF016042),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _movePhotoLeft(int index) {
    if (index <= 0 || index >= _photos.length) return;
    setState(() {
      final photo = _photos.removeAt(index);
      _photos.insert(index - 1, photo);
      _selectedPhotoIndex = index - 1;
    });
  }

  void _movePhotoRight(int index) {
    if (index < 0 || index >= _photos.length - 1) return;
    setState(() {
      final photo = _photos.removeAt(index);
      _photos.insert(index + 1, photo);
      _selectedPhotoIndex = index + 1;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      if (_selectedPhotoIndex >= _photos.length) {
        _selectedPhotoIndex = _photos.isEmpty ? 0 : _photos.length - 1;
      }
    });
  }

  void _removeVideo() {
    setState(() {
      _videoUrl = null;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Video del producto eliminado.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC05621),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddMediaModal() {
    final photoUrlCtrl = TextEditingController();
    final videoUrlCtrl = TextEditingController();
    String activeTab = _photos.length >= 8 && _videoUrl == null ? 'video' : 'photo';

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
            final isPhotoTab = activeTab == 'photo';
            final canAddPhotos = _photos.length < 8;
            final canAddVideo = _videoUrl == null;

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
                    // Header Modal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.perm_media_outlined, color: primaryColor, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Añadir Medios al Producto',
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
                    const SizedBox(height: 12),

                    // Segmented Tabs: Fotos / Video
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: outlineColor),
                      ),
                      child: Row(
                        children: [
                          // Tab Fotos
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => activeTab = 'photo'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isPhotoTab ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 16,
                                      color: isPhotoTab ? Colors.white : onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fotos (${_photos.length}/8)',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isPhotoTab ? Colors.white : onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Tab Video
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => activeTab = 'video'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isPhotoTab ? const Color(0xFF0369A1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam_outlined,
                                      size: 16,
                                      color: !isPhotoTab ? Colors.white : onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Video (${_videoUrl != null ? '1' : '0'}/1)',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: !isPhotoTab ? Colors.white : onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TAB CONTENIDO: FOTOGRAFÍAS
                    if (isPhotoTab) ...[
                      if (!canAddPhotos) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF9A04)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFC05621), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Has alcanzado el límite máximo de 8 fotografías para este producto. Si deseas agregar una nueva foto, elimina alguna de las actuales.',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7B341E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Selecciona una imagen de nuestro catálogo agrícola:',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Presets Grid
                        SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _sampleImages.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final item = _sampleImages[idx];
                              final isAsset = item['url']!.startsWith('assets/');
                              final isAlreadyAdded = _photos.contains(item['url']);
                              return GestureDetector(
                                onTap: () {
                                  if (isAlreadyAdded) return;
                                  if (_photos.length >= 8) return;
                                  setState(() {
                                    _photos.add(item['url']!);
                                    _selectedPhotoIndex = _photos.length - 1;
                                  });
                                  Navigator.of(ctx).pop();
                                },
                                child: Opacity(
                                  opacity: isAlreadyAdded ? 0.45 : 1.0,
                                  child: Container(
                                    width: 88,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isAlreadyAdded ? primaryColor : outlineColor,
                                        width: isAlreadyAdded ? 2 : 1,
                                      ),
                                      color: surfaceLow,
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                            child: isAsset
                                                ? Image.asset(
                                                    item['url']!,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        const Icon(Icons.image, color: primaryColor),
                                                  )
                                                : Image.network(
                                                    item['url']!,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        const Icon(Icons.image, color: primaryColor),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Text(
                                            isAlreadyAdded ? '✓ Agregada' : item['name']!,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: isAlreadyAdded ? primaryColor : onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          controller: photoUrlCtrl,
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
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final text = photoUrlCtrl.text.trim();
                              if (text.isNotEmpty) {
                                if (_photos.length >= 8) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Límite máximo de 8 fotos alcanzado.'),
                                      backgroundColor: errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _photos.add(text);
                                  _selectedPhotoIndex = _photos.length - 1;
                                });
                                Navigator.of(ctx).pop();
                              }
                            },
                            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                            label: Text(
                              'AGREGAR FOTO (${_photos.length}/8)',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]
                    // TAB CONTENIDO: VIDEO
                    else ...[
                      // Regla explicativa sobre el video
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0369A1).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0369A1).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.video_collection_outlined, color: Color(0xFF0369A1), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reglas de Video del Producto:',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0369A1),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '• Máximo 1 video demostrativo por producto.\n• El video siempre se quedará en la última posición del carrusel.\n• No puede colocarse como vista principal del producto.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10.5,
                                      color: onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!canAddVideo) ...[
                        // Already has video
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: outlineColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0369A1).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.play_circle_fill, color: Color(0xFF0369A1), size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Video del Producto Configurado',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: onSurface,
                                          ),
                                        ),
                                        Text(
                                          _videoUrl!,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            color: onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: errorColor,
                                    side: const BorderSide(color: errorColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    _removeVideo();
                                    setModalState(() {});
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text(
                                    'ELIMINAR VIDEO PARA CAMBIARLO',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Select video presets or custom URL
                        const Text(
                          'Selecciona un video de demostración o ingresa URL:',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_sampleVideos.length, (idx) {
                          final v = _sampleVideos[idx];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _videoUrl = v['url'];
                                });
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Video "${v['name']}" agregado (última posición).'),
                                    backgroundColor: const Color(0xFF0369A1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: surfaceLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: outlineColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_circle_outline, color: Color(0xFF0369A1), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            v['name']!,
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Duración aprox: ${v['duration']}',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.add_circle_outline, color: Color(0xFF0369A1), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        const Text(
                          'O ingresa URL directa de video (MP4 / WebM):',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: videoUrlCtrl,
                          decoration: InputDecoration(
                            hintText: 'https://ejemplo.com/video_frescura.mp4',
                            prefixIcon: const Icon(Icons.videocam_outlined, color: Color(0xFF0369A1)),
                            filled: true,
                            fillColor: surfaceLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0369A1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final text = videoUrlCtrl.text.trim();
                              if (text.isNotEmpty) {
                                setState(() {
                                  _videoUrl = text;
                                });
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Video agregado exitosamente (ubicado en última posición).'),
                                    backgroundColor: const Color(0xFF0369A1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.video_call_outlined, size: 20),
                            label: const Text(
                              'AGREGAR VIDEO (1/1)',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

    final bool hasRetail = _enableRetail && _retailConfigs.isNotEmpty;
    final bool hasWholesale = _enableWholesale && _wholesaleConfigs.isNotEmpty;

    if (!hasRetail && !hasWholesale) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Debes configurar al menos una forma de venta (Al Detalle o Por Mayor).'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFC05621),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    String finalSaleType = 'ambos';
    if (hasRetail && !hasWholesale) {
      finalSaleType = 'detalle';
    } else if (!hasRetail && hasWholesale) {
      finalSaleType = 'mayor';
    }

    final defRet = _defaultRetailConfig;
    final defWhl = _defaultWholesaleConfig;

    final double retailVal = defRet != null
        ? (double.tryParse(defRet.retailPriceCtrl.text.trim()) ?? 0.0)
        : 0.0;
    final double wholesaleVal = defWhl != null
        ? (double.tryParse(defWhl.wholesalePriceCtrl.text.trim()) ?? (retailVal * 0.8))
        : (retailVal * 0.8);

    final double displayMainPrice = (finalSaleType == 'mayor') ? wholesaleVal : retailVal;
    final String primaryUnit = defRet?.unit ?? defWhl?.unit ?? 'LB';

    final int stockVal = widget.initialProduct?['stock'] ?? 100;
    final int minAlertVal = widget.initialProduct?['minStockAlert'] ?? 10;

    final String mainImage = _photos.isNotEmpty
        ? _photos[0]
        : 'assets/images/PapaGemini.png';

    final List<UnitPricingConfig> allConfigs = [
      if (hasRetail) ..._retailConfigs,
      if (hasWholesale) ..._wholesaleConfigs,
    ];

    final unitConfigsList = allConfigs.map((c) => c.toMap()).toList();

    final productData = {
      'id': widget.initialProduct?['id'] ?? 'PROD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'badge': _selectedQuality,
      'saleType': finalSaleType,
      'price': '\$${displayMainPrice.toStringAsFixed(2)}',
      'priceNum': displayMainPrice,
      'wholesalePrice': '\$${wholesaleVal.toStringAsFixed(2)}',
      'wholesalePriceNum': wholesaleVal,
      'wholesaleMin': defWhl != null && defWhl.minWholesaleCtrl.text.trim().isNotEmpty
          ? '${defWhl.minWholesaleCtrl.text.trim()} ${defWhl.unit}'
          : '10 $primaryUnit',
      'wholesaleMax': defWhl != null && defWhl.maxWholesaleCtrl.text.trim().isNotEmpty
          ? (defWhl.maxWholesaleCtrl.text.trim().toLowerCase().contains('sin l')
              ? 'Sin límites'
              : '${defWhl.maxWholesaleCtrl.text.trim()} ${defWhl.unit}')
          : 'Sin límites',
      'unit': primaryUnit,
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
      'video': _videoUrl,
      'videoUrl': _videoUrl,
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

  void _openDetailPreview() {
    final defRet = _defaultRetailConfig;
    final defWhl = _defaultWholesaleConfig;
    final name = _nameController.text.trim().isEmpty ? 'Tomates Orgánicos' : _nameController.text.trim();

    final retail = defRet?.retailPriceCtrl.text.trim().isNotEmpty == true ? defRet!.retailPriceCtrl.text.trim() : '28.50';
    final wholesale = defWhl?.wholesalePriceCtrl.text.trim().isNotEmpty == true ? defWhl!.wholesalePriceCtrl.text.trim() : '22.00';
    final minWholesale = defWhl?.minWholesaleCtrl.text.trim().isNotEmpty == true ? defWhl!.minWholesaleCtrl.text.trim() : '10';
    final unit = defRet?.unit ?? defWhl?.unit ?? 'LB';

    final bool hasRetail = _enableRetail && _retailConfigs.isNotEmpty;
    final bool hasWholesale = _enableWholesale && _wholesaleConfigs.isNotEmpty;

    String effectiveSaleType = 'ambos';
    if (hasRetail && !hasWholesale) {
      effectiveSaleType = 'detalle';
    } else if (!hasRetail && hasWholesale) {
      effectiveSaleType = 'mayor';
    }

    final effectivePrice = _previewMode == 'mayor' ? wholesale : retail;

    final allConfigs = [
      if (hasRetail) ..._retailConfigs,
      if (hasWholesale) ..._wholesaleConfigs,
    ];

    final List<String> availableUnits = allConfigs.isNotEmpty
        ? allConfigs.map((c) => c.unit).toSet().toList()
        : ['Por Libra', 'Unidad', 'Saco', 'Caja'];

    final activePhoto = _photos.isNotEmpty
        ? _photos[_selectedPhotoIndex.clamp(0, _photos.length - 1)]
        : 'assets/images/PapaGemini.png';

    final productMap = <String, dynamic>{
      'id': widget.initialProduct?['id'] ?? 'PROD-PREVIEW',
      'name': name,
      'category': _selectedCategory,
      'badge': _selectedQuality,
      'quality': _selectedQuality,
      'saleType': effectiveSaleType,
      'price': '\$$effectivePrice',
      'priceNum': double.tryParse(effectivePrice) ?? 22.00,
      'wholesalePrice': '\$$wholesale',
      'wholesalePriceNum': double.tryParse(wholesale) ?? 22.00,
      'wholesaleMin': '$minWholesale ${defWhl?.unit ?? unit}',
      'unit': unit,
      'availableUnits': availableUnits,
      'stock': 100,
      'status': 'Disponible',
      'supplier': 'Don Pedro H.',
      'location': 'Tecomán, Colima',
      'rating': '4.8',
      'ratingCount': '124',
      'description': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Este es un producto cultivado localmente bajo estrictos estándares de calidad. Todas nuestras cosechas son seleccionadas a mano y revisadas para garantizar la mejor frescura del campo a su mesa. Nuestro proceso asegura que cada ítem mantenga sus propiedades naturales y su sabor auténtico, apoyando a los productores locales y ofreciendo un precio justo para todos.',
      'img': activePhoto,
      'image': activePhoto,
      'photos': _photos.isNotEmpty ? _photos : [activePhoto],
      'video': _videoUrl,
      'videoUrl': _videoUrl,
      'unitConfigs': allConfigs.map((c) => c.toMap()).toList(),
    };

    context.push('/product_detail', extra: productMap);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF101915) : backgroundColor;
    final cardBg = isDark ? const Color(0xFF1A2420) : surfaceColor;

    final displayName = _nameController.text.trim().isEmpty ? 'Tomates Orgánicos' : _nameController.text.trim();

    // Default configurations for live preview
    final bool hasRetail = _enableRetail && _retailConfigs.isNotEmpty;
    final bool hasWholesale = _enableWholesale && _wholesaleConfigs.isNotEmpty;
    final bool isDetailActive = _previewMode == 'detalle' ? (hasRetail || !hasWholesale) : !hasWholesale;

    final defRetail = _defaultRetailConfig;
    final defWholesale = _defaultWholesaleConfig;

    final displayRetail = defRetail?.retailPriceCtrl.text.trim().isNotEmpty == true
        ? defRetail!.retailPriceCtrl.text.trim()
        : '28.50';
    final displayRetailUnit = defRetail?.unit ?? 'Und';

    final displayWholesale = defWholesale?.wholesalePriceCtrl.text.trim().isNotEmpty == true
        ? defWholesale!.wholesalePriceCtrl.text.trim()
        : '22.00';
    final displayWholesaleUnit = defWholesale?.unit ?? 'Caja';
    final displayMin = defWholesale?.minWholesaleCtrl.text.trim().isNotEmpty == true
        ? defWholesale!.minWholesaleCtrl.text.trim()
        : '10';

    final activePhoto = _photos.isNotEmpty
        ? _photos[_selectedPhotoIndex.clamp(0, _photos.length - 1)]
        : 'assets/images/PapaGemini.png';
    final isAsset = activePhoto.startsWith('assets/');

    Color qualityBgColor = const Color(0xFFDCE9E5);
    Color qualityTextColor = const Color(0xFF016042);
    final qLower = _selectedQuality.toLowerCase();
    if (qLower.contains('segunda')) {
      qualityBgColor = const Color(0xFFFFF4E5);
      qualityTextColor = const Color(0xFFFF9A04);
    } else if (qLower.contains('tercera')) {
      qualityBgColor = const Color(0xFFFDEDED);
      qualityTextColor = const Color(0xFFF44336);
    }

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
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preview Image Header Stack
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(19),
                                ),
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: surfaceLow,
                                  child: isAsset
                                      ? Image.asset(
                                          activePhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Center(
                                            child: Icon(Icons.eco, size: 52, color: primaryColor),
                                          ),
                                        )
                                      : Image.network(
                                          activePhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Center(
                                            child: Icon(Icons.eco, size: 52, color: primaryColor),
                                          ),
                                        ),
                                ),
                              ),
                              // Top-Right Favorite Button (Círculo blanco)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x20000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border,
                                    color: Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                ),
                              ),

                              // Bottom-Right Verified Badge (Sello verde)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF047857),
                                    borderRadius: BorderRadius.circular(7),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Card Body Content
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + Price Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                          color: isDark ? Colors.white : onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Price Column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isDetailActive ? '\$$displayRetail' : '\$$displayWholesale',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: isDetailActive
                                                ? const Color(0xFF047857)
                                                : const Color(0xFF0369A1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          isDetailActive
                                              ? (displayRetailUnit == 'KG' ? 'POR KILO' : 'POR $displayRetailUnit')
                                              : 'POR MAYOR',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDetailActive
                                                ? const Color(0xFF047857)
                                                : const Color(0xFF0369A1),
                                          ),
                                        ),
                                        if (!isDetailActive)
                                          Text(
                                            '(MIN. $displayMin $displayWholesaleUnit)',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0369A1),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Sales Mode Indicator / Switcher
                                if (hasRetail && hasWholesale)
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Detalle Option
                                        GestureDetector(
                                          onTap: () => setState(() => _previewMode = 'detalle'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDetailActive
                                                  ? const Color(0xFF059669)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 13,
                                                  color: isDetailActive
                                                      ? Colors.white
                                                      : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Detalle',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDetailActive
                                                        ? Colors.white
                                                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        // Por Mayor Option
                                        GestureDetector(
                                          onTap: () => setState(() => _previewMode = 'mayor'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: !isDetailActive
                                                  ? const Color(0xFF0369A1)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.inventory_2_outlined,
                                                  size: 13,
                                                  color: !isDetailActive
                                                      ? Colors.white
                                                      : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Por Mayor',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: !isDetailActive
                                                        ? Colors.white
                                                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (hasRetail)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 13,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Al Detalle',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (hasWholesale)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0369A1).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF0369A1).withValues(alpha: 0.3)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 13,
                                          color: Color(0xFF0369A1),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Por Mayor',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 6),

                                // Category & Extra Badges Row
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF2E8),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFBBD5C7), width: 0.8),
                                      ),
                                      child: Text(
                                        _selectedCategory,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF016042),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFBAE6FD), width: 0.8),
                                      ),
                                      child: const Text(
                                        'Oferta',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0369A1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Rating & Reviews Row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '(128 reseñas)',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),
                                const Divider(
                                  color: Color(0xFFE0E3DF),
                                  thickness: 0.8,
                                  height: 1,
                                ),
                                const SizedBox(height: 6),

                                // CALIDAD Row
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: qualityBgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.workspace_premium,
                                        color: qualityTextColor,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'CALIDAD',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          Text(
                                            _selectedQuality.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: qualityTextColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                // PROVEEDOR Row
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF047857).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_florist,
                                        color: Color(0xFF047857),
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'PROVEEDOR',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          Text(
                                            'Don Pedro H.',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                // UBICACIÓN Row
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'UBICACIÓN',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          Text(
                                            'Tecomán, Colima',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Card Bottom Action Preview Bar
                                GestureDetector(
                                  onTap: _openDetailPreview,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 14,
                                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'VISTA PREVIA DE DETALLE',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 10,
                                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Additional units hint
                                if (isDetailActive && _retailConfigs.length > 1) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: surfaceLow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.touch_app_outlined, size: 13, color: primaryColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '+${_retailConfigs.length - 1} presentación(es) al detalle más (${_retailConfigs.where((c) => !c.isDefault).map((c) => c.unit).join(', ')})',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (!isDetailActive && _wholesaleConfigs.length > 1) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: surfaceLow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.touch_app_outlined, size: 13, color: Color(0xFF0369A1)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '+${_wholesaleConfigs.length - 1} presentación(es) al por mayor más (${_wholesaleConfigs.where((c) => !c.isDefault).map((c) => c.unit).join(', ')})',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0369A1),
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
                    // 2. FOTOGRAFÍAS Y VIDEO STRIP (HASTA 8 FOTOS + 1 VIDEO ANCLADO AL FINAL)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.perm_media_outlined, size: 18, color: primaryColor),
                            const SizedBox(width: 6),
                            const Text(
                              'Fotografías del Producto',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Badge contador fotos
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _photos.length >= 8
                                    ? const Color(0xFFFDEDED)
                                    : primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _photos.length >= 8 ? errorColor : primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${_photos.length}/8 Fotos',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _photos.length >= 8 ? errorColor : primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Badge contador video
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _videoUrl != null
                                    ? const Color(0xFF0369A1).withValues(alpha: 0.15)
                                    : surfaceLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _videoUrl != null ? const Color(0xFF0369A1) : outlineColor,
                                ),
                              ),
                              child: Text(
                                '${_videoUrl != null ? '1' : '0'}/1 Video',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _videoUrl != null ? const Color(0xFF0369A1) : onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'La foto #1 es la Portada Principal. Usa ◀ ▶ para ordenar o pulsa ☆ para definir la principal. El video siempre se mostrará al final.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 122,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Botón Añadir Medio (Foto o Video)
                          GestureDetector(
                            onTap: _showAddMediaModal,
                            child: Container(
                              width: 96,
                              height: 118,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: surfaceLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (_photos.length >= 8 && _videoUrl != null)
                                      ? outlineColor
                                      : primaryColor.withValues(alpha: 0.5),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    (_photos.length >= 8 && _videoUrl != null)
                                        ? Icons.check_circle_outline
                                        : Icons.add_photo_alternate_outlined,
                                    color: (_photos.length >= 8 && _videoUrl != null)
                                        ? onSurfaceVariant
                                        : primaryColor,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (_photos.length >= 8 && _videoUrl != null) ? 'COMPLETO' : 'AÑADIR',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: (_photos.length >= 8 && _videoUrl != null)
                                          ? onSurfaceVariant
                                          : primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (_photos.length >= 8 && _videoUrl != null) ? 'Límites listos' : 'Foto o Video',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 8.5,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Lista de Fotografías Reordenables (1 a 8)
                          ...List.generate(_photos.length, (index) {
                            final photo = _photos[index];
                            final isSelected = _selectedPhotoIndex == index;
                            final isAssetPhoto = photo.startsWith('assets/');
                            final isPrincipal = index == 0;

                            return Container(
                              width: 104,
                              height: 118,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isPrincipal
                                      ? const Color(0xFF016042)
                                      : (isSelected ? primaryColor : outlineColor),
                                  width: isPrincipal ? 2.5 : (isSelected ? 2.0 : 1.0),
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x0E000000), blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Imagen
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedPhotoIndex = index),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: isAssetPhoto
                                            ? Image.asset(
                                                photo,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.image),
                                              )
                                            : Image.network(
                                                photo,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.image),
                                              ),
                                      ),
                                    ),
                                  ),

                                  // Gradiente Superior para legibilidad de insignias
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.65),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Barra Superior: Tag Posición / Principal y Botón Eliminar
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    right: 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Badge de Posición
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isPrincipal
                                                ? const Color(0xFF016042)
                                                : Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isPrincipal ? const Color(0xFF34D399) : Colors.white24,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isPrincipal) ...[
                                                const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFD700)),
                                                const SizedBox(width: 2),
                                              ],
                                              Text(
                                                isPrincipal ? 'PORTADA' : '#${index + 1}',
                                                style: const TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Botón Eliminar
                                        GestureDetector(
                                          onTap: () => _removePhoto(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.92),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black26, blurRadius: 3),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 13,
                                              color: errorColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Barra Inferior de Control de Posición y Selección Principal
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.78),
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Mover hacia la izquierda (◀)
                                          GestureDetector(
                                            onTap: index > 0 ? () => _movePhotoLeft(index) : null,
                                            child: Opacity(
                                              opacity: index > 0 ? 1.0 : 0.25,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: index > 0
                                                      ? Colors.white.withValues(alpha: 0.15)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_back_ios_rounded,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Botón / Indicador Principal (★)
                                          GestureDetector(
                                            onTap: !isPrincipal ? () => _setMainPhoto(index) : null,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isPrincipal
                                                    ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                                                    : Colors.white.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isPrincipal ? Icons.star_rounded : Icons.star_border_rounded,
                                                    size: 13,
                                                    color: isPrincipal ? const Color(0xFFFFD700) : Colors.white,
                                                  ),
                                                  if (!isPrincipal) ...[
                                                    const SizedBox(width: 2),
                                                    const Text(
                                                      'Principal',
                                                      style: TextStyle(
                                                        fontFamily: 'Plus Jakarta Sans',
                                                        fontSize: 7.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Mover hacia la derecha (▶)
                                          GestureDetector(
                                            onTap: index < _photos.length - 1 ? () => _movePhotoRight(index) : null,
                                            child: Opacity(
                                              opacity: index < _photos.length - 1 ? 1.0 : 0.25,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: index < _photos.length - 1
                                                      ? Colors.white.withValues(alpha: 0.15)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // ========================================================
                          // TARJETA DE VIDEO (ESTRICTAMENTE ANCLADA AL FINAL)
                          // Siempre en la última posición, sin botones de reorden ni principal
                          // ========================================================
                          if (_videoUrl != null)
                            Container(
                              width: 104,
                              height: 118,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
                                ),
                                border: Border.all(
                                  color: const Color(0xFF38BDF8),
                                  width: 2.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x240284C7),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Top Row: Badge VIDEO y Botón Eliminar
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    right: 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFF7DD3FC), width: 0.8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.videocam, size: 10, color: Colors.white),
                                              SizedBox(width: 2),
                                              Text(
                                                'VIDEO',
                                                style: TextStyle(
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _removeVideo,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.92),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black26, blurRadius: 3),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 13,
                                              color: errorColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Centro: Icono Play representativo
                                  Positioned.fill(
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Video Demo',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Barra Inferior: Indicador Fijo de Posición (Sin flechas de mover)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.8),
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.push_pin_outlined, size: 10, color: Color(0xFF38BDF8)),
                                          SizedBox(width: 3),
                                          Text(
                                            'ÚLTIMA POSICIÓN',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF38BDF8),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  // --- Multi-Unit Pricing Section (Divided into Detalle & Por Mayor, up to 4 each) ---
  Widget _buildMultiUnitPricingSection(Color cardBg) {
    const wholesaleBlue = Color(0xFF0369A1);
    final isDetalleActive = _activePricingTab == 'detalle';

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
                      'Configura hasta 4 unidades al detalle y 4 al por mayor',
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

          // Segmented Tab Switcher: [ Al Detalle (X/4) ] | [ Por Mayor (Y/4) ]
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineColor),
            ),
            child: Row(
              children: [
                // Tab 1: Al Detalle
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activePricingTab = 'detalle';
                        _previewMode = 'detalle';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDetalleActive ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isDetalleActive
                            ? const [
                                BoxShadow(
                                  color: Color(0x2200462F),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 15,
                            color: isDetalleActive ? Colors.white : onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Al Detalle',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDetalleActive ? Colors.white : onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDetalleActive
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : onSurfaceVariant.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_retailConfigs.length}/4',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDetalleActive ? Colors.white : onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Tab 2: Por Mayor
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activePricingTab = 'mayor';
                        _previewMode = 'mayor';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: !isDetalleActive ? wholesaleBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isDetalleActive
                            ? const [
                                BoxShadow(
                                  color: Color(0x220369A1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 15,
                            color: !isDetalleActive ? Colors.white : onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Por Mayor',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: !isDetalleActive ? Colors.white : onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: !isDetalleActive
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : onSurfaceVariant.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_wholesaleConfigs.length}/4',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: !isDetalleActive ? Colors.white : onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Render active configuration section
          if (isDetalleActive)
            _buildRetailChannelSection(cardBg)
          else
            _buildWholesaleChannelSection(cardBg),
        ],
      ),
    );
  }

  // --- SECCIÓN: CONFIGURACIÓN AL DETALLE ---
  Widget _buildRetailChannelSection(Color cardBg) {
    final availUnits = _availableRetailUnits;
    final currentUnit = availUnits.contains(_newRetailUnit)
        ? _newRetailUnit
        : (availUnits.isNotEmpty ? availUnits.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Forma de Venta al Detalle Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBD5C7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: primaryColor, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forma de Venta al Detalle',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF016042),
                      ),
                    ),
                    Text(
                      'Venta por unidad o fracción para consumidor final',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        color: Color(0xFF486456),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _enableRetail,
                activeThumbColor: primaryColor,
                activeTrackColor: primaryColor.withValues(alpha: 0.5),
                onChanged: (val) {
                  if (!val && !_enableWholesale) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Debes mantener activa al menos una forma de venta (Al Detalle o Por Mayor).'),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFC05621),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _enableRetail = val;
                    if (val && _retailConfigs.isEmpty) {
                      _addRetailConfig(unit: 'Und', retailPrice: '28.50', isDefault: true);
                    }
                    if (!val && _enableWholesale) {
                      _activePricingTab = 'mayor';
                      _previewMode = 'mayor';
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (!_enableRetail)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineColor),
            ),
            child: Column(
              children: [
                Icon(Icons.storefront_outlined, size: 32, color: onSurfaceVariant.withValues(alpha: 0.6)),
                const SizedBox(height: 8),
                const Text(
                  'Forma de Venta al Detalle Deshabilitada',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Los clientes no podrán comprar este producto por unidad ni ver precios minoristas.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _enableRetail = true;
                      if (_retailConfigs.isEmpty) {
                        _addRetailConfig(unit: 'Und', retailPrice: '28.50', isDefault: true);
                      }
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text(
                    'HABILITAR VENTA AL DETALLE',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // ==========================================
          // CAJA SUPERIOR FIJA: CONFIGURACIÓN DE PRECIOS Y UNIDADES
          // ==========================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Configurar y Agregar Unidad al Detalle',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _retailConfigs.length >= 4
                            ? const Color(0xFFFDEDED)
                            : primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _retailConfigs.length >= 4 ? errorColor : primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${_retailConfigs.length}/4',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _retailConfigs.length >= 4 ? errorColor : primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_retailConfigs.length < 4 && currentUnit != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown de Unidad
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildFieldLabel('UNIDAD *'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _showUnitsInfoDialog,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 13,
                                      color: primaryColor.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DropdownButtonFormField<String>(
                              key: ValueKey('retail_$currentUnit'),
                              initialValue: currentUnit,
                              decoration: _buildInputDecoration(),
                              items: availUnits.map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    u,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _newRetailUnit = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Input de Precio
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('PRECIO AL DETALLE *'),
                            TextFormField(
                              controller: _newRetailPriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _buildInputDecoration(
                                hintText: '28.50',
                                prefixText: '\$ ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submitNewRetailUnit,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'AGREGAR UNIDAD AL DETALLE',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ] else if (_retailConfigs.length >= 4) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF9A04).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFF9A04), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Has alcanzado el límite máximo de 4 unidades al detalle. Si deseas cambiar alguna, elimínala de la lista inferior.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No hay más unidades disponibles para agregar.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Título de Unidades ya configuradas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNIDADES CONFIGURADAS (${_retailConfigs.length})',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              const Text(
                'Toca ★ para elegir la predeterminada',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Listado de Tarjetas Compactas
          ...List.generate(_retailConfigs.length, (idx) {
            final config = _retailConfigs[idx];
            return _buildRetailSummaryCard(config, idx, cardBg);
          }),
        ],
      ],
    );
  }

  // --- SECCIÓN: CONFIGURACIÓN AL POR MAYOR ---
  Widget _buildWholesaleChannelSection(Color cardBg) {
    const wholesaleBlue = Color(0xFF0369A1);
    final availUnits = _availableWholesaleUnits;
    final currentUnit = availUnits.contains(_newWholesaleUnit)
        ? _newWholesaleUnit
        : (availUnits.isNotEmpty ? availUnits.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Forma de Venta al Por Mayor Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined, color: wholesaleBlue, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forma de Venta al Por Mayor',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: wholesaleBlue,
                      ),
                    ),
                    Text(
                      'Venta por bulto, lote o volumen para negocios y comercios',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        color: Color(0xFF075985),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _enableWholesale,
                activeThumbColor: wholesaleBlue,
                activeTrackColor: wholesaleBlue.withValues(alpha: 0.5),
                onChanged: (val) {
                  if (!val && !_enableRetail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Debes mantener activa al menos una forma de venta (Al Detalle o Por Mayor).'),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFC05621),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _enableWholesale = val;
                    if (val && _wholesaleConfigs.isEmpty) {
                      _addWholesaleConfig(unit: 'Caja', wholesalePrice: '22.00', minWholesale: '10', maxWholesale: '100', isDefault: true);
                    }
                    if (!val && _enableRetail) {
                      _activePricingTab = 'detalle';
                      _previewMode = 'detalle';
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (!_enableWholesale)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineColor),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 32, color: onSurfaceVariant.withValues(alpha: 0.6)),
                const SizedBox(height: 8),
                const Text(
                  'Forma de Venta al Por Mayor Deshabilitada',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Este producto no ofrecerá precios mayoristas ni cantidades mínimas de compra por volumen.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: wholesaleBlue,
                    side: const BorderSide(color: wholesaleBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _enableWholesale = true;
                      if (_wholesaleConfigs.isEmpty) {
                        _addWholesaleConfig(unit: 'Caja', wholesalePrice: '22.00', minWholesale: '10', maxWholesale: '100', isDefault: true);
                      }
                    });
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text(
                    'HABILITAR VENTA AL POR MAYOR',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // ==========================================
          // CAJA SUPERIOR FIJA: CONFIGURACIÓN DE PRECIOS Y UNIDADES
          // ==========================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: wholesaleBlue.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: wholesaleBlue.withValues(alpha: 0.25), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: wholesaleBlue, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Configurar y Agregar Unidad al Por Mayor',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: wholesaleBlue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _wholesaleConfigs.length >= 4
                            ? const Color(0xFFFDEDED)
                            : wholesaleBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _wholesaleConfigs.length >= 4 ? errorColor : wholesaleBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${_wholesaleConfigs.length}/4',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _wholesaleConfigs.length >= 4 ? errorColor : wholesaleBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_wholesaleConfigs.length < 4 && currentUnit != null) ...[
                  // Fila 1: Unidad y Precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown de Unidad
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildFieldLabel('UNIDAD *'),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _showUnitsInfoDialog,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 13,
                                      color: wholesaleBlue.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DropdownButtonFormField<String>(
                              key: ValueKey('wholesale_$currentUnit'),
                              initialValue: currentUnit,
                              decoration: _buildInputDecoration(),
                              items: availUnits.map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    u,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _newWholesaleUnit = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Input de Precio por mayor
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('PRECIO MAYORISTA *'),
                            TextFormField(
                              controller: _newWholesalePriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  const SizedBox(height: 8),

                  // Fila 2: Venta Mínima y Venta Máxima
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venta Mínima
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('VENTA MÍNIMA'),
                            TextFormField(
                              controller: _newWholesaleMinCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hintText: '10',
                                suffixText: currentUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Venta Máxima con opción Sin límites
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildFieldLabel('VENTA MÁXIMA'),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _newWholesaleUnlimited = !_newWholesaleUnlimited;
                                      if (_newWholesaleUnlimited) {
                                        _newWholesaleMaxCtrl.clear();
                                      } else if (_newWholesaleMaxCtrl.text.isEmpty) {
                                        _newWholesaleMaxCtrl.text = '100';
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: _newWholesaleUnlimited
                                          ? wholesaleBlue
                                          : wholesaleBlue.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _newWholesaleUnlimited ? wholesaleBlue : outlineColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _newWholesaleUnlimited ? Icons.check_circle : Icons.all_inclusive,
                                          size: 11,
                                          color: _newWholesaleUnlimited ? Colors.white : wholesaleBlue,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Sin límites',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: _newWholesaleUnlimited ? Colors.white : wholesaleBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _newWholesaleMaxCtrl,
                              enabled: !_newWholesaleUnlimited,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hintText: _newWholesaleUnlimited ? 'Sin límites' : '100',
                                suffixText: _newWholesaleUnlimited ? null : currentUnit,
                                prefixIcon: _newWholesaleUnlimited ? Icons.all_inclusive : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Botón Agregar
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wholesaleBlue,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submitNewWholesaleUnit,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'AGREGAR UNIDAD AL POR MAYOR',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ] else if (_wholesaleConfigs.length >= 4) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF9A04).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFF9A04), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Has alcanzado el límite máximo de 4 unidades al por mayor. Si deseas cambiar alguna, elimínala de la lista inferior.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No hay más unidades disponibles para agregar.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Título de Unidades ya configuradas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNIDADES CONFIGURADAS (${_wholesaleConfigs.length})',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              const Text(
                'Toca ★ para elegir la predeterminada',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Listado de Tarjetas Compactas
          ...List.generate(_wholesaleConfigs.length, (idx) {
            final config = _wholesaleConfigs[idx];
            return _buildWholesaleSummaryCard(config, idx, cardBg);
          }),
        ],
      ],
    );
  }

  // --- TARJETA COMPACTA DE RESUMEN: UNIDAD AL DETALLE ---
  Widget _buildRetailSummaryCard(UnitPricingConfig config, int index, Color cardBg) {
    final bool isDefault = config.isDefault;
    final priceStr = config.retailPriceCtrl.text.trim().isNotEmpty
        ? config.retailPriceCtrl.text.trim()
        : '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDefault ? primaryColor.withValues(alpha: 0.05) : surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? primaryColor : outlineColor,
          width: isDefault ? 1.6 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Unit Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDefault ? primaryColor : onSurfaceVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              config.unit,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDefault ? Colors.white : onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Price Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$$priceStr',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              Text(
                'Al Detalle',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),

          // Star Default Chip
          GestureDetector(
            onTap: () => _setRetailDefault(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
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
                    isDefault ? 'Predeterminada' : 'Hacer default',
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
          const SizedBox(width: 6),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: errorColor, size: 19),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Eliminar esta unidad al detalle',
            onPressed: () => _removeRetailConfig(index),
          ),
        ],
      ),
    );
  }

  // --- TARJETA COMPACTA DE RESUMEN: UNIDAD AL POR MAYOR ---
  Widget _buildWholesaleSummaryCard(UnitPricingConfig config, int index, Color cardBg) {
    const wholesaleBlue = Color(0xFF0369A1);
    final bool isDefault = config.isDefault;
    final priceStr = config.wholesalePriceCtrl.text.trim().isNotEmpty
        ? config.wholesalePriceCtrl.text.trim()
        : '0.00';
    final minStr = config.minWholesaleCtrl.text.trim().isNotEmpty
        ? config.minWholesaleCtrl.text.trim()
        : '10';
    final maxStr = config.maxWholesaleCtrl.text.trim().isNotEmpty
        ? config.maxWholesaleCtrl.text.trim()
        : '100';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDefault ? wholesaleBlue.withValues(alpha: 0.05) : surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? wholesaleBlue : outlineColor,
          width: isDefault ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Unit Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDefault ? wholesaleBlue : onSurfaceVariant.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.unit,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDefault ? Colors.white : onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Price Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$$priceStr',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: wholesaleBlue,
                    ),
                  ),
                  Text(
                    'Por Mayor',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Star Default Chip
              GestureDetector(
                onTap: () => _setWholesaleDefault(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
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
                        isDefault ? 'Predeterminada' : 'Hacer default',
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
              const SizedBox(width: 6),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: errorColor, size: 19),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Eliminar esta unidad al por mayor',
                onPressed: () => _removeWholesaleConfig(index),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Tier volume indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: outlineColor, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_outlined, size: 12, color: wholesaleBlue),
                const SizedBox(width: 4),
                Text(
                  (maxStr.toLowerCase().contains('sin l') || maxStr.toLowerCase().contains('ilimitad'))
                      ? 'Volumen: Mín. $minStr ${config.unit}  •  Sin límites'
                      : 'Volumen: Mín. $minStr ${config.unit}  •  Máx. $maxStr ${config.unit}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: wholesaleBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
