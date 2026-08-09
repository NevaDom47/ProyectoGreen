import 'dart:async';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------
// Global Flash Offers State (Synchronized across screens)
// ---------------------------------------------------------
final ValueNotifier<List<Map<String, dynamic>>> globalFlashOffers = ValueNotifier([
  {
    'name': 'Papa Blanca Alpha',
    'category': 'Tubérculos',
    'discount': '-20%',
    'discountNumber': 20,
    'price': '\$18.00',
    'oldPrice': '\$22.50',
    'wholesalePrice': '\$14.50',
    'wholesaleOldPrice': '\$17.50',
    'wholesaleMin': 'MIN. 20 KG',
    'rating': '4.8',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'Don Pedro H.',
    'location': 'Tecomán, Colima',
    'tags': ['Tubérculos', 'Oferta'],
    'salesMode': 'both',
    'secondsRemaining': 10, // ⏳ 10 segundos para pruebas de expiración
    'startTime': 'hoy, 08:00 AM',
    'duration': '12 Horas',
    'img': 'assets/images/PapaGemini.png'
  },
  {
    'name': 'Zanahoria Orgánica',
    'category': 'Raíces',
    'discount': '-22%',
    'discountNumber': 22,
    'price': '\$12.50',
    'oldPrice': '\$16.00',
    'wholesalePrice': '\$9.80',
    'wholesaleOldPrice': '\$12.50',
    'wholesaleMin': 'MIN. 15 KG',
    'rating': '4.9',
    'badge': 'TERCERA CALIDAD',
    'supplier': 'Granja Sol',
    'location': 'Valle Verde, Puebla',
    'tags': ['Raíces', 'Orgánico'],
    'salesMode': 'both',
    'secondsRemaining': 20382, // 05:39:42
    'img': 'assets/images/ZanahoriaGemini.png'
  },
  {
    'name': 'Fresas de Campo Extras',
    'category': 'Frutas',
    'discount': '-25%',
    'discountNumber': 25,
    'price': '\$45.00',
    'oldPrice': '\$60.00',
    'wholesalePrice': '\$36.00',
    'wholesaleOldPrice': '\$48.00',
    'wholesaleMin': 'MIN. 10 KG',
    'rating': '4.9',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'AgroFresas',
    'location': 'Zamora, Michoacán',
    'tags': ['Frutas', 'Frescas'],
    'salesMode': 'both',
    'secondsRemaining': 7487, // 02:04:47
    'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png'
  },
  {
    'name': 'Saco de Papas Blancas',
    'category': 'Tubérculos',
    'discount': '-12%',
    'discountNumber': 12,
    'price': '\$280.00',
    'oldPrice': '\$320.00',
    'wholesalePrice': '\$250.00',
    'wholesaleOldPrice': '\$300.00',
    'wholesaleMin': 'MIN. 2 SACOS',
    'rating': '4.6',
    'badge': 'SEGUNDA CALIDAD',
    'supplier': 'Hermanos Ruiz',
    'location': 'Galeana, Nuevo León',
    'tags': ['Tubérculos'],
    'salesMode': 'wholesale_only',
    'secondsRemaining': 18867, // 05:14:27
    'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1556_Sacos%20de%20Papas_simple_compose_01jwvnskaee6evykbzreq6j8wm.png'
  },
  {
    'name': 'Tomate Cherry Orgánico',
    'category': 'Hortalizas',
    'discount': '-30%',
    'discountNumber': 30,
    'price': '\$12.50',
    'oldPrice': '\$17.85',
    'wholesalePrice': '\$9.50',
    'wholesaleOldPrice': '\$13.50',
    'wholesaleMin': 'MIN. 10 KG',
    'rating': '4.9',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'Invernaderos SLP',
    'location': 'San Luis Potosí',
    'tags': ['Hortalizas', 'Orgánico'],
    'salesMode': 'both',
    'secondsRemaining': 1256, // ⏳ 00:20:56 (< 30 min) para prueba de Por Vencer
    'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXcsVfAn4SXFQcHddnB5qMtM4renFwAuqO-lGdtcJtIIEmGl9tMDsFQiPgu60XnCWVebJO7iP0Ibk5dtJIqrh9Aanp9rZWGv7faUFsthP816CnkwG06d3lv6JAtK1L0AlnAz_e_RO8MTnW4_KInOanUlNL5k2AshcmFlzprpJxW1x81-1wvtFdgqmQ27XRJXCS6DLiTryvA9pgF60utXXNGEKTfgzyHZfbGio0iMIq4G_RBnQepN2i0vJ1-mywwHJNnmaXt1UMSH8'
  },
  {
    'name': 'Zanahoria Nantesa Lavada',
    'category': 'Raíces',
    'discount': '-50%',
    'discountNumber': 50,
    'price': '\$15.00',
    'oldPrice': '\$30.00',
    'wholesalePrice': '\$11.00',
    'wholesaleOldPrice': '\$22.00',
    'wholesaleMin': 'MIN. 20 KG',
    'rating': '4.8',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'Granja Sol',
    'location': 'Valle Verde, Puebla',
    'tags': ['Raíces', 'Lavada'],
    'salesMode': 'both',
    'secondsRemaining': 9840, // 02:44:00
    'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC8i3bYgCoFml8RIwzz2s32HSkKDvOTWEnX-bo6gt_9o4zdC9d3U0ZglOr_m6EMoKc6Oz2ryDTAoXTbMceJxM4huBHJNMRIBp_rkwcL972T0U0FipN8bSOaMvmlsOxI7peoA4M2Uq1zmuTbYTdHFlAe_A_VA3kLfbMf3thYxRRP7gU3H79Xu6gqxI8wfQqLd59xQyc9evPxWOYoH-ufQjjtXka1i6Bn6dDixAquahUTLyExdeosV0TZReH-nBZgtW2Wf1EEcK2VGiY'
  },
  {
    'name': 'Limón Sutil Primera',
    'category': 'Cítricos',
    'discount': '-25%',
    'discountNumber': 25,
    'price': '\$8.90',
    'oldPrice': '\$11.90',
    'wholesalePrice': '\$6.50',
    'wholesaleOldPrice': '\$9.20',
    'wholesaleMin': 'MIN. 15 KG',
    'rating': '4.7',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'Cítricos del Pacífico',
    'location': 'Manzanillo, Colima',
    'tags': ['Cítricos', 'Fresco'],
    'salesMode': 'both',
    'secondsRemaining': 31500, // 08:45:00
    'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro'
  },
  {
    'name': 'Mix de Ajíes Frescos',
    'category': 'Hortalizas',
    'discount': '-22%',
    'discountNumber': 22,
    'price': '\$35.00',
    'oldPrice': '\$45.00',
    'wholesalePrice': '\$28.00',
    'wholesaleOldPrice': '\$36.00',
    'wholesaleMin': 'MIN. 10 KG',
    'rating': '4.7',
    'badge': 'PRIMERA CALIDAD',
    'supplier': 'Picantes del Sur',
    'location': 'Oaxaca, Oaxaca',
    'tags': ['Hortalizas', 'Mix'],
    'salesMode': 'both',
    'secondsRemaining': 12300, // 03:25:00
    'img': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250603_1549_Variedad%20de%20Aj%C3%ADes_simple_compose_01jwvncbmqfpvb7qv6rs3vh22x.png'
  },
]);

Timer? _globalFlashTimer;

void startGlobalFlashTimer() {
  _globalFlashTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
    bool updated = false;
    final offers = List<Map<String, dynamic>>.from(globalFlashOffers.value);
    for (var offer in offers) {
      final secs = offer['secondsRemaining'] as int? ?? 0;
      if (secs > 0) {
        offer['secondsRemaining'] = secs - 1;
        updated = true;
      }
    }
    if (updated) {
      globalFlashOffers.value = offers;
    }
  });
}

final ValueNotifier<List<Map<String, dynamic>>> globalFavorites = ValueNotifier([
  {
    'name': 'Fresas Orgánicas Extras',
    'category': 'Frutas',
    'supplier': 'AgroFresas',
    'price': '\$4.50',
    'unit': 'por libra',
    'rating': '4.9',
    'quality': 'Primera Calidad',
    'tags': ['Frutas', 'Orgánico'],
    'image': 'https://raw.githubusercontent.com/NevaDom47/imagenes/refs/heads/main/20250620_1233_Fresas%20en%20Fondo%20Rosado_simple_compose_01jy72ypjmeccafrqb33rfm1q8.png',
  },
  {
    'name': 'Aguacate Hass',
    'category': 'Verduras',
    'supplier': 'Huasca Farms',
    'price': '\$2.25',
    'unit': 'por unidad',
    'rating': '5.0',
    'quality': 'Segunda Calidad',
    'tags': ['Verduras', 'Mayorista'],
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoJ0D5DucqLAya_-YteH6-8cB0lbCiusShRQ5J7CpVWmeRZq_Dunwko3RtZ6MnlwVNNLu9qIMiXPC02Jr1-ZLXltcDkkQ0pqh4QKIExzuuQRRqrcXdHQcZxH33bpROQ5o-f2IBOsbqiL6lAuXMgnbrH4_kJmNK6b8kKf_2pM4dzh8AtsiiLNaiDX88Fe0OoRYiKx2-omyEvAoG4YwfLUNLxG5W4A6kcm0dv08LBcwmXpObjY9s4lgDuy3fpuu-_bUGZXDeZUcnKro',
  },
  {
    'name': 'Tomates Cherry',
    'category': 'Verduras',
    'supplier': 'Finca La Huerta',
    'price': '\$3.10',
    'unit': 'por paquete',
    'rating': '4.7',
    'quality': 'Tercera Calidad',
    'tags': ['Verduras', 'Frescas'],
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBHOb892B5me7rsHN9BLjAtuvcsEpGo1VrRV6dP2J5F5FeDlnP9fSbAhWTNBrHo7AfCBa2UJ9hXp_j2GBSUqZg-GX-VyRBv5JXlV6MiHw_s4HSUtqGzVZ3-magpGmcXWQiyIr_8sXxrAHlcLE5lukc_T12APAyR2UuP9qfurDDd-0QzCJ-yVftAtJGCoPKTAp7_oH_h2fVZsZKNWwWUJlrN_fLxTVMmupW98Id5ESA5rGGS_XndVfkw7hHV26apec7jtihZ2G1fHgk',
  },
]);

bool isFavorite(String productName) {
  return globalFavorites.value.any((item) => item['name'] == productName);
}

void toggleFavorite(Map<String, dynamic> product) {
  final currentFavorites = List<Map<String, dynamic>>.from(globalFavorites.value);
  final index = currentFavorites.indexWhere((item) => item['name'] == product['name']);
  
  if (index >= 0) {
    currentFavorites.removeAt(index);
  } else {
    // Standardize map format if it's coming from different screens (like home feed which has 'img' instead of 'image')
    currentFavorites.add({
      'name': product['name'] ?? '',
      'category': product['category'] ?? 'General',
      'supplier': product['supplier'] ?? 'Proveedor Local',
      'price': product['price'] ?? '\$0.00',
      'unit': product['unit'] ?? 'por kilo',
      'rating': (product['rating'] ?? '5.0').toString().split(' ').first, // Keep only numericalrating if text has (xxx reviews)
      'quality': product['badge'] ?? product['quality'] ?? 'Primera calidad',
      'tags': product['tags'] ?? [],
      'image': product['img'] ?? product['image'] ?? '',
    });
  }
  
  globalFavorites.value = currentFavorites;
}

// ---------------------------------------------------------
// Global Favorite Providers
// ---------------------------------------------------------
final ValueNotifier<List<Map<String, dynamic>>> globalFavoriteProviders = ValueNotifier([]);

bool isFavoriteProvider(String providerName) {
  return globalFavoriteProviders.value.any((item) => item['name'] == providerName);
}

void toggleFavoriteProvider(Map<String, dynamic> provider) {
  final currentFavorites = List<Map<String, dynamic>>.from(globalFavoriteProviders.value);
  final index = currentFavorites.indexWhere((item) => item['name'] == provider['name']);
  
  if (index >= 0) {
    currentFavorites.removeAt(index);
  } else {
    currentFavorites.add({
      'name': provider['name'] ?? '',
      'image': provider['image'] ?? provider['url'] ?? '',
      'rating': provider['rating'] ?? '0.0',
      'distance': provider['distance'] ?? '',
      'tags': provider['tags'] ?? '',
      'verified': provider['verified'] ?? true,
    });
  }
  
  globalFavoriteProviders.value = currentFavorites;
}

// ---------------------------------------------------------
// Global Followed Sellers (Vendedores Seguidos)
// ---------------------------------------------------------
final ValueNotifier<List<Map<String, dynamic>>> globalFollowedSellers = ValueNotifier([
  {
    'name': 'Rancho La Esmeralda',
    'category': 'Frutas Orgánicas',
    'location': 'Valle de Bravo',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJfhsXWlGj_e6jMOlWQvaGR4vigrpEKd_KyyfH1d8qoThPNhJnIeI8hnsYo7dAhLKL7ZvG7H2oa5bpGwkK_SUC-JMR4httJQzBqmo-amX7XleGiCIz8iPgbQNcpjIcl_YSO705cEobBEIVPEtlQoh13N3OSj8KsFE0OEwzgV6-E0LPuzqBVZ2kAtZZX-wyU9Y8Wwh3jqkMfUx4npYT-yMETXX-_remGbLlt1VZUMnXllgXDVsBhXQdHEoQQbi5whnVa2pyW93gCFE',
    'isVerified': true,
  },
  {
    'name': 'Quesería del Valle',
    'category': 'Lácteos Artesanales',
    'location': 'Tepoztlán',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3EDGPZ5hvKmtWotekXUFESqC8YslpjM2XGKTpwHD-9BY0Z5mTAqFpV1yX_nEcnJE7VlOOfKXHgQ73gwxWA1X5LpF6S-4jw8Lh3T0GcDypcsxjTLfv-oAeEcAD5YLQ-5t23fTOMYw-wyYACFXIqlVx-4M5iEpcYbeJG_bIruh_pZB4byz5LiIpOKbd4XABzs7I6FxBuqeoxl4N_Iz4endCgswH9lQC1x_EDnb9fZI47loT5ijY8HpbPb6EBt8Ni_zLbRKUuMvlypM',
    'isVerified': true,
  },
  {
    'name': 'Huerto Urbano Beto',
    'category': 'Hortalizas',
    'location': 'CDMX, Sur',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAq1dkFq-LWEhEEmD05pVrCvd6Grh-N2TRksyTjLV_HH0I27knLZGKMkibu0G4aARGuH16ZOrdC2X1vYuNWEtz1chv7assrXH-x1jpyq4FavGos2dd7nZc4V-YpU-eohZMfWkdQ4DTI4LH_phiFDOaBVaHDIFULU4rVxD7IYZMx_I-whxiPsWPf-mMfLkv2c7lN8kHeYLIrmCGrpqaMtmCdzGWHLTJ86i0wr-_miBcBChgGJa7zJagdnQ6xX8n4-JjsG8aKVlGHmUU',
    'isVerified': false,
  },
  {
    'name': 'Pan de Masa Madre',
    'category': 'Panadería',
    'location': 'Puebla Centro',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfm1It2nHPJBElGev0Yw0vkefqeELtD4rX-m4I-5dErJckjmC9VP3JdI6-Rsw-WskeT6yUxo9vSNgPicmzkXvSqZLdz3A9DfBj_yNPkR64ClUNPk9ZCTAUKYp6DP9k1__W7z3VX-_RQYsu3PZ9a-KOucWuMU1t9HBqU9HcgkB2FBIW0LfCPd3Nrg37CGmt-QwaNmRBDhq58yRAJ4lkjqQzv0RvOZ3gQDd9BJY7pLPrduvGctAGxW--J4FV5RaebiXJoLiZyy-KMLQ',
    'isVerified': true,
  },
]);

bool isFollowingSeller(String sellerName) {
  return globalFollowedSellers.value.any((item) => item['name'] == sellerName);
}

void toggleFollowSeller(Map<String, dynamic> seller) {
  final currentFollowed = List<Map<String, dynamic>>.from(globalFollowedSellers.value);
  final index = currentFollowed.indexWhere((item) => item['name'] == seller['name']);
  
  if (index >= 0) {
    currentFollowed.removeAt(index);
  } else {
    currentFollowed.add({
      'name': seller['name'] ?? '',
      'category': seller['category'] ?? seller['tags'] ?? 'General',
      'location': seller['location'] ?? seller['distance'] ?? 'México',
      'imageUrl': seller['imageUrl'] ?? seller['img'] ?? seller['image'] ?? '',
      'isVerified': seller['isVerified'] ?? seller['verified'] ?? true,
    });
  }
  globalFollowedSellers.value = currentFollowed;
}

// ---------------------------------------------------------
// Global Cart State
// ---------------------------------------------------------
final ValueNotifier<List<Map<String, dynamic>>> globalCart = ValueNotifier([
  {
    'name': 'Granja El Sol',
    'isVerified': true,
    'delivery': 'Entrega Estimada: 30-45 min',
    'payment_method': 'Efectivo contra entrega',
    'coupon': null,
    'items': [
      {
        'name': 'Tomate Riñón Orgánico',
        'quality': 'Primera Calidad', 
        'selected_unit': 'UNIDAD',
        'available_units': ['UNIDAD', 'LIBRA'],
        'price_per_unit': 4.50,
        'quantity': 2,
        'tags': ['Orgánico', 'Local'],
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC4sULAhp9YqBiPpU_UsNJMi5SPnhYJlSmBy0iMWtO9RVDaUIRTA3dejYii8fPww71NzRSmNBQ0EquzAsRETI-WQ8tY69GSl31vBdhwDjfh0ZrXUSeJdUBSm_GoKKiMAIIwPV7Uqqmguf0Xhq5MB3hpQnh-AqEoaeBQuEZPcmYR2zB2JW4ra9ttK53wR0Dh08F9EdW6plsqxBZE6O-7BI3XnpsDfUggqfRdhB_xhze2phSlmxyZop1Bw57nRXePWBfLhMgveXwxr5s',
      }
    ]
  },
  {
    'name': 'Huerto Los Andes',
    'isVerified': true,
    'delivery': 'Entrega Estimada: 60 min',
    'payment_method': 'Transferencia Bancaria',
    'coupon': null,
    'items': [
      {
        'name': 'Aguacate Hass Premium',
        'quality': 'Segunda Calidad',
        'selected_unit': 'UNIDAD',
        'available_units': ['UNIDAD', 'LIBRA', 'SACO', 'CAJA'],
        'price_per_unit': 2.75,
        'quantity': 5,
        'tags': ['Exportación', 'Premium'],
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCx_eRxHSK6aT1dCBg3UZ21drqrz2a64dmGPr8oTG0AwxQg0tDHVh4AtgkqDL9nFU3WpSX7wpX-mqCzxe8EVd07TtoyRnGyMKSGzfqVdkh_j7V_WDyzIsqHtCn4ZTDR6b7aC1H3c0x9tVl_JkgdHXVc331TsEehHQuMybFAM2rM-_9QQlVy3Su13zKGeSWfPfrF5gFM-iyyAGPQc-_F_W34y3Acj64mtVxWzV11ufTeMWIzML5WRRVceAYqKkB1F4P_yYDKiV2M4QA',
      }
    ]
  }
]);

void addToCart(Map<String, dynamic> product) {
  final currentCart = List<Map<String, dynamic>>.from(globalCart.value);
  
  final supplierName = product['supplier'] ?? 'Proveedor Local';
  
  // Try to find if vendor already exists
  final vendorIndex = currentCart.indexWhere((v) => v['name'] == supplierName);
  
  // Parse item price
  double itemPrice = 0.0;
  if (product['price'] != null) {
    String priceStr = product['price'].toString().replaceAll('\$', '');
    itemPrice = double.tryParse(priceStr) ?? 0.0;
  }

  // Define limits (same as in CartScreen mostly) minimum 1
  int initialQuantity = 1;
  String unit = (product['unit'] ?? product['overlayText'] ?? 'UNIDAD').toString().toUpperCase().replaceAll('POR ', '');
  if (unit != 'UNIDAD' && unit != 'LIBRA' && unit != 'SACO' && unit != 'CAJA' && unit != 'KILO') {
    unit = 'UNIDAD';
  }

  final newItem = {
    'name': product['name'] ?? 'Producto Adicional',
    'quality': product['quality'] ?? product['badge'] ?? 'General',
    'selected_unit': unit,
    'available_units': [unit],
    'price_per_unit': itemPrice,
    'quantity': initialQuantity,
    'tags': product['tags'] ?? [],
    'img': product['image'] ?? product['img'] ?? '',
  };

  if (vendorIndex >= 0) {
    // Vendor exists, insert into items list
    final vendor = Map<String, dynamic>.from(currentCart[vendorIndex]);
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(vendor['items'] ?? []);
    
    // Check if product already exists, if so, increase quantity
    final existingItemIndex = items.indexWhere((item) => item['name'] == newItem['name'] && item['selected_unit'] == newItem['selected_unit']);
    if (existingItemIndex >= 0) {
      final existingItem = Map<String, dynamic>.from(items[existingItemIndex]);
      existingItem['quantity'] = (existingItem['quantity'] as int) + 1;
      items[existingItemIndex] = existingItem;
    } else {
      items.add(newItem);
    }
    
    vendor['items'] = items;
    currentCart[vendorIndex] = vendor;
  } else {
    // Vendor doesn't exist, create it
    final newVendor = {
      'name': supplierName,
      'isVerified': true,
      'delivery': 'Entrega Estimada: 24h',
      'payment_method': 'Efectivo contra entrega',
      'coupon': null,
      'items': [newItem],
    };
    currentCart.add(newVendor);
  }

  globalCart.value = currentCart;
}

bool isInCart(Map<String, dynamic> product) {
  final supplierName = product['supplier'] ?? 'Proveedor Local';
  final vendorIndex = globalCart.value.indexWhere((v) => v['name'] == supplierName);
  if (vendorIndex >= 0) {
    final items = globalCart.value[vendorIndex]['items'] as List;
    return items.any((item) => item['name'] == product['name']);
  }
  return false;
}

// ---------------------------------------------------------
// Global Order History State (Historial de Pedidos)
// ---------------------------------------------------------
final ValueNotifier<List<Map<String, dynamic>>> globalOrders = ValueNotifier([
  {
    'id': '#ORD-88291',
    'invoice_no': '#FAC-88291',
    'title': 'Caja de Aguacate Hass',
    'price': '\$40.00',
    'seller': 'Huerta Los Arcos',
    'date': '12 Oct 2023',
    'status': 'Entregado',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2ZIB05xpVqKmcAF9RrIklerMhV-2ElP_Ylbv5Atdu4NTuCoG3V30iMDwUk1T3ZSP6fOqLSrRQOa3iyzVmUeHJs5Kj8fviLwFJRzKKvF0VWruRgt9XqpnYo1kEQlLt2ypJT0mjuAjS_s6iXVlDe1fkqYr0km8Ju_vFeJJ7LXRuEQTR8fqWHZix0C_lP6PEbBPPnfBCF46oMVI8Im35b00BhCcmRk5xQHdTk4AFXFLjPwO_VX2q_g0AncbtgDW07A5Pyjy7DaN5JDU',
    'payment_method': 'Efectivo contra entrega',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '1 caja',
    'initial_price': '\$45.00 / caja',
    'final_price': '\$40.00 / caja',
    'items': [
      {
        'name': 'Caja de Aguacate Hass',
        'quality': 'Primera Calidad',
        'price': '\$40.00',
        'quantity': 1,
        'unit': 'caja',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2ZIB05xpVqKmcAF9RrIklerMhV-2ElP_Ylbv5Atdu4NTuCoG3V30iMDwUk1T3ZSP6fOqLSrRQOa3iyzVmUeHJs5Kj8fviLwFJRzKKvF0VWruRgt9XqpnYo1kEQlLt2ypJT0mjuAjS_s6iXVlDe1fkqYr0km8Ju_vFeJJ7LXRuEQTR8fqWHZix0C_lP6PEbBPPnfBCF46oMVI8Im35b00BhCcmRk5xQHdTk4AFXFLjPwO_VX2q_g0AncbtgDW07A5Pyjy7DaN5JDU'
      }
    ],
    'subtotal': '\$40.00',
    'delivery_fee': '\$5.00',
    'total': '\$45.00'
  },
  {
    'id': '#ORD-78192',
    'invoice_no': '#FAC-78192',
    'title': 'Papas Orgánicas (5kg)',
    'price': '\$10.00',
    'seller': 'Rancho San José',
    'date': 'Hoy, 10:30 AM',
    'status': 'En camino',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmYjLRMiY7WyNMucxG4CWhBqDjld4g1fh3sa0Zz99DUAVWn3ONFY5gGQocSt_dZb09JIMot022OqJmPmZRk5IrEaKqK6zRHPRtYZhTpMdrsqsQDp5z_fmahRSTk3cvy6CXe_gRlq_UxhKPPQRtVIq1jTiG863BYq5UW1yD4V52_bTc_nLqMH94qXEj8XOmrF-6L3s2la6xa9zQiYCXaaWorrIl9K5a5wTWI6Ofw8I3ZrHIKViB7qFXPm6_LM1kBryMX2Tvt7D6Pw',
    'payment_method': 'Transferencia Bancaria',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '5 kg',
    'initial_price': '\$12.50 / saco',
    'final_price': '\$10.00 / saco',
    'items': [
      {
        'name': 'Papas Orgánicas (5kg)',
        'quality': 'Segunda Calidad',
        'price': '\$10.00',
        'quantity': 1,
        'unit': 'saco 5kg',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmYjLRMiY7WyNMucxG4CWhBqDjld4g1fh3sa0Zz99DUAVWn3ONFY5gGQocSt_dZb09JIMot022OqJmPmZRk5IrEaKqK6zRHPRtYZhTpMdrsqsQDp5z_fmahRSTk3cvy6CXe_gRlq_UxhKPPQRtVIq1jTiG863BYq5UW1yD4V52_bTc_nLqMH94qXEj8XOmrF-6L3s2la6xa9zQiYCXaaWorrIl9K5a5wTWI6Ofw8I3ZrHIKViB7qFXPm6_LM1kBryMX2Tvt7D6Pw'
      }
    ],
    'subtotal': '\$10.00',
    'delivery_fee': '\$3.00',
    'total': '\$13.00'
  },
  {
    'id': '#ORD-62104',
    'invoice_no': '#FAC-62104',
    'title': 'Saco de Maíz Blanco (20kg)',
    'price': '\$28.00',
    'seller': 'Rancho San Francisco',
    'date': '08 Oct 2023',
    'status': 'Entregado',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfm1It2nHPJBElGev0Yw0vkefqeELtD4rX-m4I-5dErJckjmC9VP3JdI6-Rsw-WskeT6yUxo9vSNgPicmzkXvSqZLdz3A9DfBj_yNPkR64ClUNPk9ZCTAUKYp6DP9k1__W7z3VX-_RQYsu3PZ9a-KOucWuMU1t9HBqU9HcgkB2FBIW0LfCPd3Nrg37CGmt-QwaNmRBDhq58yRAJ4lkjqQzv0RvOZ3gQDd9BJY7pLPrduvGctAGxW--J4FV5RaebiXJoLiZyy-KMLQ',
    'payment_method': 'Efectivo contra entrega',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '20 kg',
    'initial_price': '\$32.00 / saco',
    'final_price': '\$28.00 / saco',
    'items': [
      {
        'name': 'Saco de Maíz Blanco (20kg)',
        'quality': 'Primera Calidad',
        'price': '\$28.00',
        'quantity': 1,
        'unit': 'saco 20kg',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfm1It2nHPJBElGev0Yw0vkefqeELtD4rX-m4I-5dErJckjmC9VP3JdI6-Rsw-WskeT6yUxo9vSNgPicmzkXvSqZLdz3A9DfBj_yNPkR64ClUNPk9ZCTAUKYp6DP9k1__W7z3VX-_RQYsu3PZ9a-KOucWuMU1t9HBqU9HcgkB2FBIW0LfCPd3Nrg37CGmt-QwaNmRBDhq58yRAJ4lkjqQzv0RvOZ3gQDd9BJY7pLPrduvGctAGxW--J4FV5RaebiXJoLiZyy-KMLQ'
      }
    ],
    'subtotal': '\$28.00',
    'delivery_fee': '\$6.00',
    'total': '\$34.00'
  },
  {
    'id': '#ORD-59821',
    'invoice_no': '#FAC-59821',
    'title': 'Queso Fresco de Rancho (3kg)',
    'price': '\$16.50',
    'seller': 'Quesería del Valle',
    'date': '28 Sep 2023',
    'status': 'Entregado',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3EDGPZ5hvKmtWotekXUFESqC8YslpjM2XGKTpwHD-9BY0Z5mTAqFpV1yX_nEcnJE7VlOOfKXHgQ73gwxWA1X5LpF6S-4jw8Lh3T0GcDypcsxjTLfv-oAeEcAD5YLQ-5t23fTOMYw-wyYACFXIqlVx-4M5iEpcYbeJG_bIruh_pZB4byz5LiIpOKbd4XABzs7I6FxBuqeoxl4N_Iz4endCgswH9lQC1x_EDnb9fZI47loT5ijY8HpbPb6EBt8Ni_zLbRKUuMvlypM',
    'payment_method': 'Transferencia Bancaria',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '3 kg',
    'initial_price': '\$18.00 / pieza',
    'final_price': '\$16.50 / pieza',
    'items': [
      {
        'name': 'Queso Fresco de Rancho (3kg)',
        'quality': 'Primera Calidad',
        'price': '\$16.50',
        'quantity': 1,
        'unit': 'pieza 3kg',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3EDGPZ5hvKmtWotekXUFESqC8YslpjM2XGKTpwHD-9BY0Z5mTAqFpV1yX_nEcnJE7VlOOfKXHgQ73gwxWA1X5LpF6S-4jw8Lh3T0GcDypcsxjTLfv-oAeEcAD5YLQ-5t23fTOMYw-wyYACFXIqlVx-4M5iEpcYbeJG_bIruh_pZB4byz5LiIpOKbd4XABzs7I6FxBuqeoxl4N_Iz4endCgswH9lQC1x_EDnb9fZI47loT5ijY8HpbPb6EBt8Ni_zLbRKUuMvlypM'
      }
    ],
    'subtotal': '\$16.50',
    'delivery_fee': '\$4.00',
    'total': '\$20.50'
  },
  {
    'id': '#ORD-41295',
    'invoice_no': '#FAC-41295',
    'title': 'Canasta de Verduras Mixtas',
    'price': '\$22.50',
    'seller': 'Huerto Urbano Beto',
    'date': '15 Sep 2023',
    'status': 'Cancelado',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAq1dkFq-LWEhEEmD05pVrCvd6Grh-N2TRksyTjLV_HH0I27knLZGKMkibu0G4aARGuH16ZOrdC2X1vYuNWEtz1chv7assrXH-x1jpyq4FavGos2dd7nZc4V-YpU-eohZMfWkdQ4DTI4LH_phiFDOaBVaHDIFULU4rVxD7IYZMx_I-whxiPsWPf-mMfLkv2c7lN8kHeYLIrmCGrpqaMtmCdzGWHLTJ86i0wr-_miBcBChgGJa7zJagdnQ6xX8n4-JjsG8aKVlGHmUU',
    'payment_method': 'Efectivo contra entrega',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '1 canasta',
    'initial_price': '\$22.50 / canasta',
    'final_price': '\$22.50 / canasta',
    'cancel_reason': 'Sin acuerdo de precio',
    'items': [
      {
        'name': 'Canasta de Verduras Mixtas',
        'quality': 'Segunda Calidad',
        'price': '\$22.50',
        'quantity': 1,
        'unit': 'canasta',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAq1dkFq-LWEhEEmD05pVrCvd6Grh-N2TRksyTjLV_HH0I27knLZGKMkibu0G4aARGuH16ZOrdC2X1vYuNWEtz1chv7assrXH-x1jpyq4FavGos2dd7nZc4V-YpU-eohZMfWkdQ4DTI4LH_phiFDOaBVaHDIFULU4rVxD7IYZMx_I-whxiPsWPf-mMfLkv2c7lN8kHeYLIrmCGrpqaMtmCdzGWHLTJ86i0wr-_miBcBChgGJa7zJagdnQ6xX8n4-JjsG8aKVlGHmUU'
      }
    ],
    'subtotal': '\$22.50',
    'delivery_fee': '\$5.00',
    'total': '\$27.50'
  },
  {
    'id': '#ORD-39102',
    'invoice_no': '#FAC-39102',
    'title': 'Miel de Abeja Orgánica (1L)',
    'price': '\$13.50',
    'seller': 'Rancho La Esmeralda',
    'date': '05 Sep 2023',
    'status': 'Entregado',
    'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJfhsXWlGj_e6jMOlWQvaGR4vigrpEKd_KyyfH1d8qoThPNhJnIeI8hnsYo7dAhLKL7ZvG7H2oa5bpGwkK_SUC-JMR4httJQzBqmo-amX7XleGiCIz8iPgbQNcpjIcl_YSO705cEobBEIVPEtlQoh13N3OSj8KsFE0OEwzgV6-E0LPuzqBVZ2kAtZZX-wyU9Y8Wwh3jqkMfUx4npYT-yMETXX-_remGbLlt1VZUMnXllgXDVsBhXQdHEoQQbi5whnVa2pyW93gCFE',
    'payment_method': 'Transferencia Bancaria',
    'shipping_address': 'Av. de la Reforma 222, Colonia Juárez, Ciudad de México',
    'quantity_label': '1 L',
    'initial_price': '\$15.00 / L',
    'final_price': '\$13.50 / L',
    'items': [
      {
        'name': 'Miel de Abeja Orgánica (1L)',
        'quality': 'Primera Calidad',
        'price': '\$13.50',
        'quantity': 1,
        'unit': 'botella 1L',
        'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJfhsXWlGj_e6jMOlWQvaGR4vigrpEKd_KyyfH1d8qoThPNhJnIeI8hnsYo7dAhLKL7ZvG7H2oa5bpGwkK_SUC-JMR4httJQzBqmo-amX7XleGiCIz8iPgbQNcpjIcl_YSO705cEobBEIVPEtlQoh13N3OSj8KsFE0OEwzgV6-E0LPuzqBVZ2kAtZZX-wyU9Y8Wwh3jqkMfUx4npYT-yMETXX-_remGbLlt1VZUMnXllgXDVsBhXQdHEoQQbi5whnVa2pyW93gCFE'
      }
    ],
    'subtotal': '\$13.50',
    'delivery_fee': '\$3.00',
    'total': '\$16.50'
  }
]);

// Dynamically computed sequential invoice ID generator
int _lastGeneratedSequence = 0;

String generateNextInvoiceId() {
  if (_lastGeneratedSequence == 0) {
    int maxNum = 88291; // Seed starting number
    for (var order in globalOrders.value) {
      final inv = order['invoice_no'] as String?;
      if (inv != null && inv.startsWith('#FAC-')) {
        final numStr = inv.replaceFirst('#FAC-', '');
        final num = int.tryParse(numStr);
        if (num != null && num > maxNum) {
          maxNum = num;
        }
      }
      final id = order['id'] as String?;
      if (id != null && id.startsWith('#FAC-')) {
        final numStr = id.replaceFirst('#FAC-', '');
        final num = int.tryParse(numStr);
        if (num != null && num > maxNum) {
          maxNum = num;
        }
      }
    }
    _lastGeneratedSequence = maxNum;
  }
  _lastGeneratedSequence += 1;
  return '#FAC-$_lastGeneratedSequence';
}



