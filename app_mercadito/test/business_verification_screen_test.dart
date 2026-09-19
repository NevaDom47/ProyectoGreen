import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/business_verification_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

void main() {
  setUp(() {
    UserSession.clear();
    UserSession.fullName = 'Agropecuaria El Valle';
  });

  tearDown(() {
    UserSession.clear();
  });

  testWidgets('BusinessVerificationScreen renders initial not_submitted state with form fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Verificación de Negocio'), findsOneWidget);

    // Verify Requirements/Benefits Card
    expect(find.text('Beneficios de la Verificación Formal'), findsOneWidget);
    expect(find.textContaining('Insignia oficial azul en tu perfil'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Nombre Comercial / Razón Social'), findsOneWidget);
    expect(find.text('RNC o Cédula Tributaria (DGII)'), findsOneWidget);
    expect(find.text('Categoría del Negocio'), findsOneWidget);

    // Verify Document Upload Cards (Camera Photo Capture in initial uncaptured state)
    expect(find.text('Registro Mercantil Vigente'), findsWidgets);
    expect(find.text('Cédula / ID del Representante Legal'), findsOneWidget);
    expect(find.text('Comprobante de Domicilio / Finca'), findsOneWidget);
    expect(find.text('Tomar Foto'), findsNWidgets(3));
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(3));

    // Verify Submit Button is present
    expect(find.text('ENVIAR SOLICITUD DE VERIFICACIÓN'), findsOneWidget);
  });

  testWidgets('BusinessVerificationScreen validates required fields, checkbox and document photos', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to submit button and tap without accepting declaration
    final submitBtn = find.text('ENVIAR SOLICITUD DE VERIFICACIÓN');
    await tester.scrollUntilVisible(submitBtn, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify validation message for terms
    expect(find.text('Debes certificar la veracidad de los datos para continuar'), findsOneWidget);

    // Dismiss SnackBar
    ScaffoldMessenger.of(tester.element(find.byType(BusinessVerificationScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Check declaration checkbox
    final checkbox = find.byType(Checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Enter valid 9-digit RNC
    final rncField = find.widgetWithText(TextFormField, 'Ej. 1-32-45678-9');
    await tester.enterText(rncField, '131456789');
    await tester.pumpAndSettle();

    // Submit without taking photos validates document photos
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.text('Debes tomar la fotografía de los 3 documentos requeridos con la cámara'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(BusinessVerificationScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Scroll up to capture each required photo
    final firstTomarFoto = find.text('Tomar Foto').first;
    await tester.scrollUntilVisible(firstTomarFoto, -300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('Tomar Foto').first);
      await tester.pumpAndSettle();
      ScaffoldMessenger.of(tester.element(find.byType(BusinessVerificationScreen))).clearSnackBars();
      await tester.pumpAndSettle();
    }

    // Verify all 3 cards transitioned to green with checkmarks and 'Cambiar'
    expect(find.text('Cambiar'), findsNWidgets(3));
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsNWidgets(3));

    // Submit request now that all fields and photos are present
    await tester.scrollUntilVisible(submitBtn, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify status changed to pending
    expect(UserSession.isVerificationPending, isTrue);
    expect(find.text('Solicitud de Verificación en Revisión'), findsOneWidget);
    expect(find.textContaining('Tus documentos fiscales y comerciales están siendo verificados'), findsOneWidget);
  });

  testWidgets('BusinessVerificationScreen demo tools allow testing verified, rejected, and 30-day lockout states', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap demo tool in AppBar
    final demoBtn = find.byTooltip('Simulador / Demo');
    expect(demoBtn, findsOneWidget);
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();

    // Verify Demo Modal opens with all options
    expect(find.text('Simulación de Verificación (Demo)'), findsOneWidget);
    expect(find.text('Aprobar como Verificado'), findsOneWidget);
    expect(find.text('Marcar En Revisión (Pending)'), findsOneWidget);
    expect(find.text('Simular 1 Rechazo (Intento 1 de 3)'), findsOneWidget);
    expect(find.text('Simular 3 Rechazos (Bloqueo 30 días)'), findsOneWidget);
    expect(find.text('Restablecer a No Solicitado'), findsOneWidget);

    // 1. Test Approved State
    await tester.tap(find.text('Aprobar como Verificado'));
    await tester.pumpAndSettle();

    expect(UserSession.isProviderVerified, isTrue);
    expect(UserSession.canSubmitVerification, isFalse);
    expect(find.text('¡Perfil de Negocio Verificado!'), findsOneWidget);
    expect(find.textContaining('1-32-45678-9'), findsWidgets);
    expect(find.text('Este negocio cuenta con la insignia oficial de confianza.'), findsOneWidget);
    expect(find.text('NEGOCIO YA VERIFICADO (VOLVER)'), findsOneWidget);

    // 2. Test 1 Rejection (can retry)
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simular 1 Rechazo (Intento 1 de 3)'));
    await tester.pumpAndSettle();

    expect(UserSession.isVerificationRejected, isTrue);
    expect(UserSession.verificationRejectionCount, 1);
    expect(UserSession.canSubmitVerification, isTrue);
    expect(find.textContaining('Documentación con Observaciones (Intento 1 de 3)'), findsOneWidget);
    expect(find.textContaining('El nombre comercial indicado no concuerda'), findsOneWidget);
    expect(find.text('REINTENTAR SOLICITUD DE VERIFICACIÓN'), findsOneWidget);

    // 3. Test 3 Rejections (30-day Lockout)
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simular 3 Rechazos (Bloqueo 30 días)'));
    await tester.pumpAndSettle();

    expect(UserSession.isVerificationLockedOut, isTrue);
    expect(UserSession.canSubmitVerification, isFalse);
    expect(UserSession.verificationRejectionCount, 3);
    expect(find.textContaining('Límite de Intentos Alcanzado (Bloqueo de 30 Días)'), findsOneWidget);
    expect(find.textContaining('no puedes enviar otra solicitud hasta transcurrir 30 días'), findsOneWidget);
    expect(find.textContaining('BLOQUEADO POR 30 DÍAS'), findsOneWidget);
    expect(find.text('Bloqueado'), findsNWidgets(3));

    // 4. Test Pending State via demo
    await tester.tap(demoBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar En Revisión (Pending)'));
    await tester.pumpAndSettle();

    expect(UserSession.isVerificationPending, isTrue);
    expect(UserSession.canSubmitVerification, isFalse);
    expect(find.text('Solicitud de Verificación en Revisión'), findsOneWidget);
    expect(find.textContaining('No puedes enviar otra solicitud hasta que obtengas una respuesta'), findsOneWidget);
    expect(find.text('SOLICITUD EN REVISIÓN (ESPERANDO RESPUESTA)'), findsOneWidget);
  });

  testWidgets('BusinessVerificationScreen updates legal document title dynamically and captures camera photo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial title is the default selected document: Registro Mercantil Vigente
    expect(find.text('Registro Mercantil Vigente'), findsWidgets);

    // Open dropdown for legal document type
    final dropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Documento Legal Principal');
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Select 'Constancia de Inscripción al RNC (DGII)'
    final newOption = find.text('Constancia de Inscripción al RNC (DGII)').last;
    await tester.tap(newOption);
    await tester.pumpAndSettle();

    // Verify Section 2 title dynamically updated to the selected document
    expect(find.text('Constancia de Inscripción al RNC (DGII)'), findsWidgets);

    // Verify initial uncaptured state has Tomar Foto and unchecked icon
    expect(find.text('Tomar Foto'), findsNWidgets(3));
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(3));

    // Scroll to Section 2 card and tap Tomar Foto button on the first document card to trigger camera capture
    final tomarFotoBtn = find.text('Tomar Foto').first;
    await tester.scrollUntilVisible(tomarFotoBtn, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(tomarFotoBtn);
    await tester.pumpAndSettle();

    // Verify confirmation feedback and transition to green checked state with Cambiar button
    expect(find.textContaining('capturada con la cámara'), findsOneWidget);
    expect(find.text('Cambiar'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('BusinessVerificationScreen enforces lockout rules and rejection limit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Simulate 3 rejections on UserSession directly
    UserSession.rejectVerification('Primer rechazo');
    UserSession.rejectVerification('Segundo rechazo');
    UserSession.rejectVerification('Tercer rechazo');

    expect(UserSession.isVerificationLockedOut, isTrue);
    expect(UserSession.lockoutDaysRemaining, greaterThanOrEqualTo(29));
    expect(UserSession.canSubmitVerification, isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify lockout banner and disabled button
    expect(find.textContaining('Límite de Intentos Alcanzado (Bloqueo de 30 Días)'), findsOneWidget);
    expect(find.textContaining('BLOQUEADO POR 30 DÍAS'), findsOneWidget);
    expect(find.text('Bloqueado'), findsNWidgets(3));

    // Resetting verification clears lockout
    UserSession.resetVerification();
    expect(UserSession.isVerificationLockedOut, isFalse);
    expect(UserSession.canSubmitVerification, isTrue);
  });
}
