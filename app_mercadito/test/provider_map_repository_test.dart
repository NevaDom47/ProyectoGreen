import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/provider_map_item.dart';
import 'package:app_mercadito/repositories/provider_map_repository.dart';

void main() {
  group('ProviderMapItem & Filter Unit Tests', () {
    const mockItem = ProviderMapItem(
      id: 'prov_test_1',
      name: 'Finca El Cibao',
      rating: '4.9',
      sector: 'Sector Gurabo • Santiago',
      distance: 'A 4 km',
      level: 'Nivel 4',
      verified: true,
      open: true,
      closeTime: '18:00',
      specialty: 'Frutas y verduras',
      salesType: 'Mayorista',
      reviews: '50 reseñas',
      traded: '300 productos',
      img: 'https://example.com/finca.jpg',
      latitude: 19.4517,
      longitude: -70.6970,
    );

    test('ProviderMapItem getters and json serialization work correctly', () {
      expect(mockItem.coordinates.latitude, 19.4517);
      expect(mockItem.coordinates.longitude, -70.6970);

      final json = mockItem.toJson();
      expect(json['id'], 'prov_test_1');
      expect(json['verified'], isTrue);
      expect(json['specialty'], 'Frutas y verduras');

      final deserialized = ProviderMapItem.fromJson(json);
      expect(deserialized.id, mockItem.id);
      expect(deserialized.name, mockItem.name);
      expect(deserialized.latitude, mockItem.latitude);
      expect(deserialized.longitude, mockItem.longitude);
      expect(deserialized.verified, isTrue);
    });

    test('ProviderMapFilter matches verified, specialty, salesType and query correctly', () {
      // 1. All match default
      expect(const ProviderMapFilter().matches(mockItem), isTrue);

      // 2. Verified match
      expect(const ProviderMapFilter(onlyVerified: true).matches(mockItem), isTrue);
      final unverified = mockItem.copyWith(verified: false);
      expect(const ProviderMapFilter(onlyVerified: true).matches(unverified), isFalse);

      // 3. Specialty match
      expect(const ProviderMapFilter(specialty: 'Frutas y verduras').matches(mockItem), isTrue);
      expect(const ProviderMapFilter(specialty: 'Huevos').matches(mockItem), isFalse);

      // 4. SalesType match
      expect(const ProviderMapFilter(salesType: 'Mayorista').matches(mockItem), isTrue);
      expect(const ProviderMapFilter(salesType: 'Al Detalle').matches(mockItem), isFalse);

      // 5. Search query match
      expect(const ProviderMapFilter(searchQuery: 'Cibao').matches(mockItem), isTrue);
      expect(const ProviderMapFilter(searchQuery: 'Santiago').matches(mockItem), isTrue);
      expect(const ProviderMapFilter(searchQuery: 'verduras').matches(mockItem), isTrue);
      expect(const ProviderMapFilter(searchQuery: 'Barahona').matches(mockItem), isFalse);

      // 6. Open filter match
      expect(const ProviderMapFilter(onlyOpen: true).matches(mockItem), isTrue);
      final closed = mockItem.copyWith(open: false);
      expect(const ProviderMapFilter(onlyOpen: true).matches(closed), isFalse);
    });
  });

  group('ProviderMapRepository Tests', () {
    late ProviderMapRepository repository;

    setUp(() {
      repository = ProviderMapRepository();
    });

    test('Returns default Dominican Republic providers (12 seed providers)', () async {
      final providers = await repository.getProviders();
      expect(providers.length, 12);

      // All coordinates must be within Dominican Republic boundary box
      // Lat: 17.5 to 20.0, Lng: -72.0 to -68.3
      for (final p in providers) {
        expect(p.latitude >= 17.5 && p.latitude <= 20.0, isTrue,
            reason: '${p.name} latitude ${p.latitude} out of DR bounds');
        expect(p.longitude >= -72.0 && p.longitude <= -68.3, isTrue,
            reason: '${p.name} longitude ${p.longitude} out of DR bounds');
      }
    });

    test('Filters providers by verified and specialty', () async {
      final verifiedOnly = await repository.getProviders(
        filter: const ProviderMapFilter(onlyVerified: true),
      );
      expect(verifiedOnly.every((p) => p.verified), isTrue);

      final lacteosOnly = await repository.getProviders(
        filter: const ProviderMapFilter(specialty: 'Lacteos'),
      );
      expect(lacteosOnly.every((p) => p.specialty == 'Lacteos'), isTrue);
      expect(lacteosOnly.length, greaterThanOrEqualTo(2));
    });

    test('getProviderById returns correct provider or null', () async {
      final provider = await repository.getProviderById('prov_huerta_arcos');
      expect(provider, isNotNull);
      expect(provider!.name, 'Huerta Los Arcos');

      final notFound = await repository.getProviderById('non_existent_id');
      expect(notFound, isNull);
    });
  });
}
