import 'package:latlong2/latlong.dart';

class ProviderMapItem {
  final String id;
  final String name;
  final String rating;
  final String sector;
  final String distance;
  final String level;
  final bool verified;
  final bool open;
  final String closeTime;
  final String specialty;
  final String salesType; // 'Mayorista', 'Al Detalle', 'Ambos'
  final String reviews;
  final String traded;
  final String img;
  final double latitude;
  final double longitude;

  const ProviderMapItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.sector,
    required this.distance,
    required this.level,
    required this.verified,
    required this.open,
    required this.closeTime,
    required this.specialty,
    required this.salesType,
    required this.reviews,
    required this.traded,
    required this.img,
    required this.latitude,
    required this.longitude,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  String get formattedCloseTime => formatTo12h(closeTime);

  static String formatTo12h(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return '6:00 PM';
    if (RegExp(r'\b(AM|PM|am|pm)\b').hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(trimmed);
    if (match != null) {
      final hour24 = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);
      if (hour24 != null && minute != null) {
        final period = hour24 >= 12 ? 'PM' : 'AM';
        var hour12 = hour24 % 12;
        if (hour12 == 0) hour12 = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour12:$minuteStr $period';
      }
    }
    return trimmed;
  }

  ProviderMapItem copyWith({
    String? id,
    String? name,
    String? rating,
    String? sector,
    String? distance,
    String? level,
    bool? verified,
    bool? open,
    String? closeTime,
    String? specialty,
    String? salesType,
    String? reviews,
    String? traded,
    String? img,
    double? latitude,
    double? longitude,
  }) {
    return ProviderMapItem(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      sector: sector ?? this.sector,
      distance: distance ?? this.distance,
      level: level ?? this.level,
      verified: verified ?? this.verified,
      open: open ?? this.open,
      closeTime: closeTime ?? this.closeTime,
      specialty: specialty ?? this.specialty,
      salesType: salesType ?? this.salesType,
      reviews: reviews ?? this.reviews,
      traded: traded ?? this.traded,
      img: img ?? this.img,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'sector': sector,
      'distance': distance,
      'level': level,
      'verified': verified,
      'open': open,
      'closeTime': closeTime,
      'specialty': specialty,
      'salesType': salesType,
      'reviews': reviews,
      'traded': traded,
      'img': img,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ProviderMapItem.fromJson(Map<String, dynamic> json) {
    return ProviderMapItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rating: json['rating'] as String? ?? '5.0',
      sector: json['sector'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      level: json['level'] as String? ?? 'Nivel 1',
      verified: json['verified'] as bool? ?? false,
      open: json['open'] as bool? ?? false,
      closeTime: json['closeTime'] as String? ?? '18:00',
      specialty: (json['specialty'] ?? json['tags']) as String? ?? 'Varios',
      salesType: json['salesType'] as String? ?? 'Ambos',
      reviews: json['reviews'] as String? ?? '0 reseñas',
      traded: json['traded'] as String? ?? '0 productos',
      img: json['img'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.7357,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -70.1627,
    );
  }
}

class ProviderMapFilter {
  final String searchQuery;
  final String specialty; // 'Todas' or specific specialty
  final bool onlyVerified;
  final String salesType; // 'Todos', 'Mayorista', 'Al Detalle', 'Ambos'
  final bool onlyOpen;

  const ProviderMapFilter({
    this.searchQuery = '',
    this.specialty = 'Todas',
    this.onlyVerified = false,
    this.salesType = 'Todos',
    this.onlyOpen = false,
  });

  ProviderMapFilter copyWith({
    String? searchQuery,
    String? specialty,
    bool? onlyVerified,
    String? salesType,
    bool? onlyOpen,
  }) {
    return ProviderMapFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      specialty: specialty ?? this.specialty,
      onlyVerified: onlyVerified ?? this.onlyVerified,
      salesType: salesType ?? this.salesType,
      onlyOpen: onlyOpen ?? this.onlyOpen,
    );
  }

  bool matches(ProviderMapItem item) {
    if (onlyVerified && !item.verified) {
      return false;
    }
    if (onlyOpen && !item.open) {
      return false;
    }
    if (specialty != 'Todas' &&
        item.specialty.toLowerCase() != specialty.toLowerCase()) {
      return false;
    }
    if (salesType != 'Todos') {
      if (salesType == 'Ambos') {
        if (item.salesType != 'Ambos') return false;
      } else {
        if (item.salesType != salesType && item.salesType != 'Ambos') {
          return false;
        }
      }
    }
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      final matchName = item.name.toLowerCase().contains(query);
      final matchSector = item.sector.toLowerCase().contains(query);
      final matchSpecialty = item.specialty.toLowerCase().contains(query);
      if (!matchName && !matchSector && !matchSpecialty) {
        return false;
      }
    }
    return true;
  }
}
