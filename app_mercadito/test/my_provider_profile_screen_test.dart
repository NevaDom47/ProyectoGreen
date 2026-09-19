import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/my_provider_profile_screen.dart';
import 'package:app_mercadito/screens/business_hours_screen.dart';
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

  testWidgets('Email field cannot be edited in edit profile modal', (tester) async {
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

    // Verify email field is disabled and security message is shown
    expect(
      find.text('El correo electrónico está vinculado a tu cuenta y no puede modificarse por seguridad.'),
      findsOneWidget,
    );
    final emailField = tester.widget<TextField>(find.widgetWithText(TextField, 'contacto@mercadito.com'));
    expect(emailField.enabled, isFalse);
  });

  testWidgets('Seller policies can be configured and updated dynamically', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.sellerPolicies = null;
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to Políticas del Vendedor card and tap its Gestionar button
    final policiesSection = find.text('Políticas del Vendedor');
    await tester.scrollUntilVisible(
      policiesSection,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final gestionarPoliciesBtn = find.text('Gestionar').at(1);
    await tester.tap(gestionarPoliciesBtn);
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Políticas del Vendedor'), findsWidgets);
    expect(find.text('Guardar Políticas'), findsOneWidget);

    // Add a new policy
    final newPolicyInput = find.widgetWithText(TextField, 'Nueva Política');
    await tester.enterText(newPolicyInput, 'Entregas certificadas en menos de 24 horas');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Save policies
    await tester.tap(find.text('Guardar Políticas'));
    await tester.pumpAndSettle();

    // Verify new policy appears on screen
    expect(find.text('Entregas certificadas en menos de 24 horas'), findsOneWidget);
  });

  testWidgets('Business hours can be managed and updated dynamically', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to Horario de Atención and tap Gestionar
    final gestionarBtn = find.text('Gestionar').first;
    await tester.scrollUntilVisible(
      gestionarBtn,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(gestionarBtn);
    await tester.pumpAndSettle();

    // Verify BusinessHoursScreen is open with the exact onboarding configuration layout
    expect(find.text('Horario'), findsOneWidget);
    expect(find.text('Configura los días y horarios en los que tu negocio estará disponible.'), findsOneWidget);
    expect(find.text('Aplicar mismo horario a todos los días'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Martes'), findsOneWidget);
    expect(find.text('Apertura'), findsWidgets);
    expect(find.text('Cierre'), findsWidgets);
    expect(find.text('GUARDAR HORARIO'), findsOneWidget);

    // Tap quick action to apply same schedule to all days
    await tester.tap(find.text('Aplicar mismo horario a todos los días'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(tester.element(find.byType(BusinessHoursScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Save hours
    await tester.tap(find.widgetWithText(ElevatedButton, 'GUARDAR HORARIO'));
    await tester.pumpAndSettle();

    // Verify returning to profile and updated schedule is displayed
    expect(find.text('Horario de Atención'), findsWidgets);
    expect(find.text('8:00 AM - 6:00 PM'), findsWidgets);
  });

  testWidgets('Business verification card and settings tile open BusinessVerificationScreen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify verification card in profile
    final verificationCard = find.text('Insignia Oficial de Negocio Verificado');
    await tester.scrollUntilVisible(verificationCard, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(verificationCard, findsOneWidget);
    expect(find.text('Solicitar Insignia'), findsOneWidget);

    // Tap Solicitar Insignia button
    await tester.tap(find.text('Solicitar Insignia'));
    await tester.pumpAndSettle();

    // Verify BusinessVerificationScreen opens
    expect(find.text('Verificación de Negocio'), findsOneWidget);
    expect(find.text('Beneficios de la Verificación Formal'), findsOneWidget);

    // Pop back to profile
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();

    // Scroll to Settings Menu and verify verification tile was removed from the options list
    expect(find.text('Verificación de Negocio (Insignia Oficial)'), findsNothing);
    expect(find.text('Editar Información de Negocio'), findsOneWidget);
    expect(find.text('Ajustes de Cuenta General'), findsOneWidget);
  });

  testWidgets('Verified provider displays verified badge next to name and verified card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    UserSession.approveVerification();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify verified badge next to name in header
    expect(find.byIcon(Icons.verified), findsWidgets);
    expect(find.text('Ricardo Mendoza'), findsOneWidget);

    // Verify verified status card
    final verifiedCard = find.text('Insignia de Negocio Verificado Activa');
    await tester.scrollUntilVisible(verifiedCard, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(verifiedCard, findsOneWidget);
    expect(find.text('Ver Acreditación'), findsOneWidget);
  });

  testWidgets('Provider profile displays pending status and 30-day lockout card correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    // 1. Pending state: cannot send another request until response
    UserSession.verificationStatus = 'pending';

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final pendingCard = find.text('Verificación en Proceso de Revisión');
    await tester.scrollUntilVisible(pendingCard, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(pendingCard, findsOneWidget);
    expect(find.textContaining('No podrás enviar otra solicitud hasta recibir una respuesta'), findsOneWidget);

    // 2. 3 Rejections: 30-day lockout
    UserSession.rejectVerification('1er rechazo');
    UserSession.rejectVerification('2do rechazo');
    UserSession.rejectVerification('3er rechazo');

    await tester.pumpWidget(
      const MaterialApp(
        home: MyProviderProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final lockoutCard = find.text('Verificación Bloqueada por 30 Días');
    await tester.scrollUntilVisible(lockoutCard, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(lockoutCard, findsOneWidget);
    expect(find.textContaining('Has alcanzado 3 intentos rechazados'), findsOneWidget);
    expect(find.textContaining('Consultar Bloqueo'), findsOneWidget);
  });

  testWidgets('MyProviderProfileScreen displays reputation card with confidence pillars and 7 criteria', (tester) async {
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

    // Verify Reputation Card Header
    final repHeader = find.text('REPUTACIÓN DEL PROVEEDOR');
    await tester.scrollUntilVisible(repHeader, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(repHeader, findsOneWidget);
    expect(find.text('Evaluación directa y cumplimiento comercial'), findsOneWidget);
    expect(find.textContaining('4.8 · 127 reseñas'), findsOneWidget);

    // Verify 3 Confidence Pillars
    expect(find.text('Cumplimiento'), findsNWidgets(2)); // pillar & criteria
    expect(find.text('Responde rápido'), findsOneWidget);
    expect(find.text('Lo recomiendan'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('93%'), findsOneWidget);
    expect(find.text('96%'), findsOneWidget);

    // Verify Desglose de Calidad de Negociación and 7 criteria
    expect(find.text('Desglose de Calidad de Negociación'), findsOneWidget);
    expect(find.text('Recomendación'), findsOneWidget);
    expect(find.text('Calidad del servicio'), findsOneWidget);
    expect(find.text('Puntualidad'), findsOneWidget);
    expect(find.text('Comunicación'), findsOneWidget);
    expect(find.text('Confiabilidad'), findsOneWidget);
    expect(find.text('Correspondencia con lo ofrecido'), findsOneWidget);
  });
}

