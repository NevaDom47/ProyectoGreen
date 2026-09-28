import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/privacy_service.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/screens/privacy_screen.dart';
import 'package:app_mercadito/screens/buyer_profile_screen.dart';
import 'package:app_mercadito/screens/provider_profile_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage)
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final List<int> _transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    PrivacyService.resetToDefaults();
    UserSession.clear();
  });

  tearDown(() {
    PrivacyService.resetToDefaults();
    UserSession.clear();
  });

  group('PrivacyService Unit Tests', () {
    test('Default values are initialized properly', () {
      final buyer = PrivacyService.buyerSettings;
      expect(buyer.showProfilePicture, isTrue);
      expect(buyer.showName, isTrue);
      expect(buyer.showLocation, isTrue);
      expect(buyer.showPublicProfile, isTrue);
      expect(buyer.showNegotiationHistory, isTrue);
      expect(buyer.showLoyaltyLevel, isTrue);
      expect(buyer.showShoppingPreferences, isTrue);
      expect(buyer.allowProviderOffers, isTrue);

      final provider = PrivacyService.providerSettings;
      expect(provider.showLocation, isTrue);
      expect(provider.showContactInfo, isTrue);
      expect(provider.showBusinessHours, isTrue);
      expect(provider.showOnlineStatus, isTrue);
      expect(provider.showLastSeen, isTrue);
    });

    test('Updating buyer settings notifies listeners and persists', () {
      bool notified = false;
      PrivacyService.buyerNotifier.addListener(() {
        notified = true;
      });

      PrivacyService.saveBuyerSettings(
        PrivacyService.buyerSettings.copyWith(
          showName: false,
          allowProviderOffers: false,
        ),
      );

      expect(notified, isTrue);
      expect(PrivacyService.buyerSettings.showName, isFalse);
      expect(PrivacyService.buyerSettings.allowProviderOffers, isFalse);
      expect(PrivacyService.buyerSettings.showProfilePicture, isTrue);
    });

    test('Updating provider settings notifies listeners and persists', () {
      bool notified = false;
      PrivacyService.providerNotifier.addListener(() {
        notified = true;
      });

      PrivacyService.saveProviderSettings(
        PrivacyService.providerSettings.copyWith(
          showLocation: false,
          showOnlineStatus: false,
        ),
      );

      expect(notified, isTrue);
      expect(PrivacyService.providerSettings.showLocation, isFalse);
      expect(PrivacyService.providerSettings.showOnlineStatus, isFalse);
      expect(PrivacyService.providerSettings.showContactInfo, isTrue);
    });
  });

  group('PrivacyScreen Widget Tests', () {
    testWidgets('Renders all Buyer privacy options by default for comprador', (tester) async {
      UserSession.selectedRole = 'comprador';

      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & role indicator
      expect(find.text('Privacidad del Perfil'), findsOneWidget);
      expect(find.text('Comprador'), findsWidgets);
      expect(find.text('Proveedor'), findsWidgets);

      // Verify all 8 Buyer options
      expect(find.text('Mostrar foto de perfil'), findsOneWidget);
      expect(find.text('Mostrar nombre'), findsOneWidget);
      expect(find.text('Mostrar ubicación'), findsOneWidget);
      expect(find.text('Mostrar perfil público'), findsOneWidget);
      expect(find.text('Mostrar Historial de negociaciones'), findsOneWidget);
      expect(find.text('Mostrar Nivel de fidelidad'), findsOneWidget);
      expect(find.text('Mostrar Preferencia de compras'), findsOneWidget);
      expect(find.text('Permitir que proveedores me envíen ofertas'), findsOneWidget);

      // Security section & Save button
      expect(find.text('Usuarios Reportados'), findsOneWidget);
      expect(find.text('Eliminar mi cuenta'), findsOneWidget);
      expect(find.text('Guardar Configuración'), findsOneWidget);
    });

    testWidgets('Renders all Provider privacy options when role is proveedor', (tester) async {
      UserSession.selectedRole = 'proveedor';

      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 5 Provider options
      expect(find.text('Mostrar ubicación'), findsOneWidget);
      expect(find.text('Mostrar información de contacto'), findsOneWidget);
      expect(find.text('Mostrar horario de atención'), findsOneWidget);
      expect(find.text('Mostrar "En línea"'), findsOneWidget);
      expect(find.text('Mostrar última conexión'), findsOneWidget);

      // Buyer specific options should not be visible in provider view
      expect(find.text('Permitir que proveedores me envíen ofertas'), findsNothing);
    });

    testWidgets('Switching role tab toggles between Buyer and Provider settings', (tester) async {
      UserSession.selectedRole = 'comprador';

      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Starts in Comprador mode
      expect(find.text('Mostrar foto de perfil'), findsOneWidget);

      // Tap Proveedor button in role selector
      await tester.tap(find.text('Proveedor'));
      await tester.pumpAndSettle();

      // Now in Proveedor mode
      expect(find.text('Mostrar información de contacto'), findsOneWidget);
      expect(find.text('Mostrar "En línea"'), findsOneWidget);
      expect(find.text('Mostrar foto de perfil'), findsNothing);
    });

    testWidgets('Toggling switches and saving updates PrivacyService', (tester) async {
      UserSession.selectedRole = 'comprador';

      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find switch for 'Mostrar nombre' and toggle it
      final nombreSwitchFinder = find.widgetWithText(SwitchListTile, 'Mostrar nombre');
      expect(nombreSwitchFinder, findsOneWidget);
      await tester.tap(nombreSwitchFinder);
      await tester.pumpAndSettle();

      // Tap Guardar Configuración
      await tester.tap(find.text('Guardar Configuración'));
      await tester.pumpAndSettle();

      // Verify setting was saved
      expect(PrivacyService.buyerSettings.showName, isFalse);
    });
  });

  group('Functional Privacy Impact on Profiles', () {
    testWidgets('BuyerProfileScreen hides sensitive data when buyer privacy options are disabled', (tester) async {
      // Configure buyer privacy with restrictions
      PrivacyService.saveBuyerSettings(
        const BuyerPrivacySettings(
          showProfilePicture: false,
          showName: false,
          showLocation: false,
          showPublicProfile: true,
          showNegotiationHistory: false,
          showLoyaltyLevel: false,
          showShoppingPreferences: false,
          allowProviderOffers: false,
        ),
      );

      final mockBuyer = {
        'id': 'BUY-99991',
        'name': 'Carlos Rodríguez',
        'avatar': 'https://example.com/avatar.jpg',
        'location': 'Sector Piantini • Santo Domingo',
        'sector': 'Sector Piantini',
        'level': 'Nivel 3',
        'negotiationsCount': 20,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: BuyerProfileScreen(buyer: mockBuyer),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Name is masked
      expect(find.text('Carlos Rodríguez'), findsNothing);
      expect(find.textContaining('Comprador #BUY-99991'), findsOneWidget);

      // 2. Location is masked
      expect(find.text('Sector Piantini'), findsNothing);
      expect(find.text('Ubicación privada'), findsOneWidget);

      // 3. Loyalty level pill is omitted
      expect(find.text('Nivel 3'), findsNothing);

      // 4. Offer button reflects disabled status
      expect(find.text('Ofertas Ocultas'), findsOneWidget);

      // 5. Shopping preferences section is omitted
      expect(find.text('Preferencias de Compra y Productos Frecuentes'), findsNothing);
    });

    testWidgets('BuyerProfileScreen shows private profile barrier when showPublicProfile is false', (tester) async {
      UserSession.selectedRole = 'proveedor'; // viewing as a provider

      PrivacyService.saveBuyerSettings(
        const BuyerPrivacySettings(
          showPublicProfile: false,
          showName: true,
        ),
      );

      final mockBuyer = {
        'id': 'BUY-99992',
        'name': 'Juan Pérez',
        'location': 'Santiago',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: BuyerProfileScreen(buyer: mockBuyer),
        ),
      );
      await tester.pumpAndSettle();

      // Should render the private profile barrier
      expect(find.text('Perfil Privado'), findsOneWidget);
      expect(find.textContaining('ha configurado su perfil como privado'), findsOneWidget);
    });

    testWidgets('ProviderProfileScreen masks location, contact, and hours when provider privacy is disabled', (tester) async {
      PrivacyService.saveProviderSettings(
        const ProviderPrivacySettings(
          showLocation: false,
          showContactInfo: false,
          showBusinessHours: false,
          showOnlineStatus: false,
          showLastSeen: false,
        ),
      );

      final mockProvider = {
        'name': 'Granja San Juan',
        'sector': 'Sector La Vega',
        'distance': '3 km',
        'code': '#PRO-12345',
        'open': true,
        'closeTime': '6:00 PM',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderProfileScreen(provider: mockProvider),
        ),
      );
      // Wait for skeleton animation to complete
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Location in header is masked
      expect(find.text('Ubicación no visible por privacidad'), findsOneWidget);

      // Business hours chip in header is omitted
      expect(find.text('ABIERTO AHORA'), findsNothing);

      // Last seen in header is omitted
      expect(find.text('En línea hace 10 min'), findsNothing);
    });
  });
}
