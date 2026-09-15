import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/my_provider_profile_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

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
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
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
  0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    UserSession.fullName = 'Ricardo Mendoza';
    UserSession.specialty = 'Orgánico';
    UserSession.salesType = 'Al Detalle';
    UserSession.state = 'San Pedro';
    UserSession.businessDescription = 'dfgdfgdfg';
  });

  testWidgets('MyProviderProfileScreen renders Bento stats and opens rating breakdown', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Sector
    expect(find.text('Mi Perfil de Negocio'), findsOneWidget);
    expect(find.text('Sector San Pedro, Guanajuato'), findsOneWidget);

    // Verify Action button
    expect(find.text('Ver como Cliente (Vista Previa)'), findsOneWidget);
    // The 3 buttons have been removed
    expect(find.text('Editar'), findsNothing);
    expect(find.text('+ Producto'), findsNothing);
    expect(find.text('Ofertas'), findsNothing);

    // Verify Bento cards
    expect(find.text('CALIFICACIÓN'), findsOneWidget);
    expect(find.text('RESEÑAS'), findsOneWidget);
    expect(find.text('NEGOCIACIONES'), findsOneWidget);

    // Verify Sobre Mi is view-only
    expect(find.text('Sobre Mi'), findsOneWidget);
    expect(find.text('dfgdfgdfg'), findsOneWidget);
    expect(find.text('¡Cuéntale tu historia a los clientes!'), findsNothing);
    expect(find.text('Redactar descripción'), findsNothing);

    // Tap Bento Rating card
    await tester.tap(find.text('CALIFICACIÓN'));
    await tester.pumpAndSettle();

    // Verify bottom sheet opened
    expect(find.text('Calificaciones y Reputación'), findsOneWidget);
    expect(find.text('124 opiniones'), findsOneWidget);
    expect(find.text('Ver Todas las Reseñas de Clientes'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Scroll down to Settings Menu and tap 'Editar Información de Negocio'
    final settingsTile = find.text('Editar Información de Negocio');
    await tester.scrollUntilVisible(
      settingsTile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(settingsTile);
    await tester.pumpAndSettle();

    // Verify that Editar Perfil modal opens
    expect(find.text('Editar Perfil de Negocio'), findsOneWidget);
    expect(find.text('Guardar Cambios'), findsOneWidget);
  });

  testWidgets('Business name cannot be changed within 3 months and shows restriction info', (tester) async {
    UserSession.businessNameLastChangedDate = DateTime.now().subtract(const Duration(days: 30));

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.businessNameLastChangedDate = null;
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final settingsTile = find.text('Editar Información de Negocio');
    await tester.scrollUntilVisible(
      settingsTile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(settingsTile);
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Editar Perfil de Negocio'), findsOneWidget);

    // Verify restriction message is shown
    expect(find.textContaining('El nombre del negocio solo se puede cambiar cada 3 meses. Próximo cambio disponible en'), findsOneWidget);

    // Verify TextField is disabled
    final textField = tester.widget<TextField>(find.widgetWithText(TextField, 'Ricardo Mendoza'));
    expect(textField.enabled, isFalse);
  });
}
