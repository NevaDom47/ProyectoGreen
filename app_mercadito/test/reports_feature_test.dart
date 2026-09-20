import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/models/user_report.dart';
import 'package:app_mercadito/services/reports_service.dart';
import 'package:app_mercadito/widgets/report_user_bottom_sheet.dart';
import 'package:app_mercadito/screens/reports_screen.dart';
import 'package:app_mercadito/screens/reported_users_screen.dart';

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
  0x60, 0x82
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('UserReport Domain Model & Invariants Tests', () {
    test('Valid report passes validation and has correct character length', () {
      final report = UserReport(
        id: 'REP-TEST-001',
        createdAt: DateTime.now(),
        reporterId: 'BUY-101',
        reporterName: 'Restaurante Prueba',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-202',
        reportedName: 'Agro Finca El Valle',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Constanza, La Vega',
        reasons: ['Calidad inferior a la ofrecida en catálogo'],
        comment: 'El lote de tomates llegó en malas condiciones.',
      );

      expect(report.validate(), isNull);
      expect(report.isValid, isTrue);
      expect(report.charactersLength, equals('El lote de tomates llegó en malas condiciones.'.length));
      expect(report.charactersLength, lessThanOrEqualTo(200));
    });

    test('Self-reporting fails validation with clear error message', () {
      final report = UserReport(
        id: 'REP-TEST-SELF',
        createdAt: DateTime.now(),
        reporterId: 'BUY-00000001',
        reporterName: 'Juan Pérez',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'BUY-00000001',
        reportedName: 'Juan Pérez',
        reportedRole: 'comprador',
        reportedAvatar: '',
        reportedLocation: 'Cuauhtémoc, CDMX',
        reasons: ['Otro motivo'],
        comment: 'Intento de auto-reporte.',
      );

      expect(report.validate(), equals('No puedes reportarte a ti mismo.'));
      expect(report.isValid, isFalse);
    });

    test('Empty comment fails validation with strict mandatory requirement', () {
      final report = UserReport(
        id: 'REP-TEST-002',
        createdAt: DateTime.now(),
        reporterId: 'BUY-101',
        reporterName: 'Restaurante Prueba',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-202',
        reportedName: 'Agro Finca El Valle',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Constanza',
        reasons: ['Cobros indebidos o alteración de precio pactado'],
        comment: '   ', // whitespace only
      );

      expect(report.validate(), equals('El comentario es obligatorio para generar un reporte.'));
      expect(report.isValid, isFalse);
    });

    test('Comment exceeding 200 characters fails validation', () {
      final longComment = 'A' * 201;
      final report = UserReport(
        id: 'REP-TEST-003',
        createdAt: DateTime.now(),
        reporterId: 'PROV-202',
        reporterName: 'Agro Finca El Valle',
        reporterRole: 'proveedor',
        reporterAvatar: '',
        reportedId: 'BUY-101',
        reportedName: 'Restaurante Prueba',
        reportedRole: 'comprador',
        reportedAvatar: '',
        reportedLocation: 'Santo Domingo',
        reasons: ['Falta de pago o retraso injustificado en transferencia'],
        comment: longComment,
      );

      expect(report.validate(), equals('El comentario no puede exceder los 200 caracteres.'));
      expect(report.isValid, isFalse);
    });

    test('Empty reasons list fails validation', () {
      final report = UserReport(
        id: 'REP-TEST-004',
        createdAt: DateTime.now(),
        reporterId: 'BUY-101',
        reporterName: 'Restaurante Prueba',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-202',
        reportedName: 'Agro Finca El Valle',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Constanza',
        reasons: [],
        comment: 'Comentario válido.',
      );

      expect(report.validate(), equals('Debe seleccionar al menos un motivo del reporte.'));
      expect(report.isValid, isFalse);
    });

    test('JSON serialization and deserialization preserves all fields', () {
      final original = UserReport(
        id: 'REP-TEST-005',
        createdAt: DateTime(2026, 9, 19, 14, 30),
        reporterId: 'BUY-88291',
        reporterName: 'Carlos Comprador',
        reporterRole: 'comprador',
        reporterAvatar: 'https://example.com/avatar.jpg',
        reporterContact: '+1 809-555-0101',
        reportedId: 'PROV-9942',
        reportedName: 'Pedro Proveedor',
        reportedRole: 'proveedor',
        reportedAvatar: 'https://example.com/prov.jpg',
        reportedLocation: 'San José de Ocoa',
        reasons: ['Entrega tardía o entrega incompleta'],
        comment: 'No entregaron los 10 sacos acordados en la orden.',
        status: 'in_review',
        resolutionNotes: 'Caso asignado al equipo de mediación.',
      );

      final json = original.toJson();
      final reconstituted = UserReport.fromJson(json);

      expect(reconstituted.id, equals(original.id));
      expect(reconstituted.reporterId, equals(original.reporterId));
      expect(reconstituted.reporterName, equals(original.reporterName));
      expect(reconstituted.reportedId, equals(original.reportedId));
      expect(reconstituted.reportedName, equals(original.reportedName));
      expect(reconstituted.reportedRole, equals(original.reportedRole));
      expect(reconstituted.reasons, equals(original.reasons));
      expect(reconstituted.comment, equals(original.comment));
      expect(reconstituted.status, equals(original.status));
      expect(reconstituted.resolutionNotes, equals(original.resolutionNotes));
    });

    test('copyWith produces expected updated immutable copy', () {
      final original = UserReport(
        id: 'REP-TEST-006',
        createdAt: DateTime.now(),
        reporterId: 'BUY-101',
        reporterName: 'Restaurante',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-202',
        reportedName: 'Productor',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'La Vega',
        reasons: ['Otro motivo'],
        comment: 'Prueba de copyWith.',
        status: 'pending',
      );

      final updated = original.copyWith(
        status: 'resolved',
        resolutionNotes: 'Solución acordada.',
      );

      expect(updated.id, equals(original.id));
      expect(updated.status, equals('resolved'));
      expect(updated.resolutionNotes, equals('Solución acordada.'));
      expect(original.status, equals('pending')); // Immutability preserved
    });
  });

  group('ReportsService Business Logic & Reactivity Tests', () {
    setUp(() {
      ReportsService.instance.resetToMockData();
    });

    test('Service initializes with mock reports and reactive count', () {
      final service = ReportsService.instance;
      expect(service.allReports.isNotEmpty, isTrue);
      expect(service.pendingCount, greaterThan(0));
    });

    test('submitReport adds valid report to notifier', () {
      final service = ReportsService.instance;
      final initialCount = service.allReports.length;

      final newReport = UserReport(
        id: 'REP-NEW-999',
        createdAt: DateTime.now(),
        reporterId: 'BUY-999',
        reporterName: 'Nuevo Reportero',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-888',
        reportedName: 'Proveedor Denunciado',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Moca, Espaillat',
        reasons: ['Calidad inferior a la ofrecida en catálogo'],
        comment: 'Falta de frescura evidente en los vegetales.',
        status: 'pending',
      );

      service.submitReport(newReport);

      expect(service.allReports.length, equals(initialCount + 1));
      expect(service.allReports.first.id, equals('REP-NEW-999'));
      expect(service.getReportById('REP-NEW-999'), isNotNull);
    });

    test('submitReport throws ArgumentError for invalid reports', () {
      final service = ReportsService.instance;

      final invalidReport = UserReport(
        id: 'REP-INVALID',
        createdAt: DateTime.now(),
        reporterId: 'BUY-999',
        reporterName: 'Test',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-888',
        reportedName: 'Test',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'RD',
        reasons: ['Otro'],
        comment: '', // Empty comment
      );

      expect(() => service.submitReport(invalidReport), throwsA(isA<ArgumentError>()));
    });

    test('updateReportStatus changes status and resolvedAt', () {
      final service = ReportsService.instance;
      final first = service.allReports.first;

      final success = service.updateReportStatus(
        first.id,
        'resolved',
        resolutionNotes: 'Caso resuelto con éxito.',
      );

      expect(success, isTrue);
      final updated = service.getReportById(first.id);
      expect(updated?.status, equals('resolved'));
      expect(updated?.resolutionNotes, equals('Caso resuelto con éxito.'));
      expect(updated?.resolvedAt, isNotNull);
    });

    test('deleteReport removes report', () {
      final service = ReportsService.instance;
      final firstId = service.allReports.first.id;
      final initialCount = service.allReports.length;

      final success = service.deleteReport(firstId);
      expect(success, isTrue);
      expect(service.allReports.length, equals(initialCount - 1));
      expect(service.getReportById(firstId), isNull);
    });

    test('submitReport throws StateError when active report already exists between users', () {
      final service = ReportsService.instance;
      service.resetToMockData();

      final report1 = UserReport(
        id: 'REP-UNIQUE-001',
        createdAt: DateTime.now(),
        reporterId: 'BUY-UNIQUE-A',
        reporterName: 'Buyer Unique A',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-UNIQUE-B',
        reportedName: 'Provider Unique B',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Santo Domingo',
        reasons: const ['Calidad inferior a la ofrecida en catálogo'],
        comment: 'Primer reporte válido.',
        status: 'pending',
      );
      service.submitReport(report1);

      expect(service.hasActiveReport('BUY-UNIQUE-A', 'PROV-UNIQUE-B'), isTrue);

      final duplicateReport = UserReport(
        id: 'REP-UNIQUE-002',
        createdAt: DateTime.now(),
        reporterId: 'BUY-UNIQUE-A',
        reporterName: 'Buyer Unique A',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'PROV-UNIQUE-B',
        reportedName: 'Provider Unique B',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Santo Domingo',
        reasons: const ['Entrega tardía o entrega incompleta'],
        comment: 'Segundo reporte duplicado.',
        status: 'pending',
      );

      expect(() => service.submitReport(duplicateReport), throwsA(isA<StateError>()));

      service.updateReportStatus('REP-UNIQUE-001', 'resolved');
      expect(service.hasActiveReport('BUY-UNIQUE-A', 'PROV-UNIQUE-B'), isFalse);

      expect(() => service.submitReport(duplicateReport), returnsNormally);
    });
  });

  group('Reports UI Widget Tests', () {
    setUp(() {
      ReportsService.instance.resetToMockData();
    });

    testWidgets('ReportUserBottomSheet validates mandatory comment and renders reasons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportUserBottomSheet(
              reportedId: 'PROV-999',
              reportedName: 'Granja San Juan',
              reportedRole: 'proveedor',
              reportedAvatar: '',
              reportedLocation: 'San Juan, RD',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title and reported user name
      expect(find.text('Reportar Proveedor'), findsOneWidget);
      expect(find.text('Granja San Juan'), findsOneWidget);
      expect(find.textContaining('PROV-999'), findsOneWidget);

      // Check counter initially 0 / 200
      expect(find.text('0 / 200'), findsOneWidget);

      // Tap submit without selecting reason and without comment
      await tester.tap(find.text('Enviar Reporte'));
      await tester.pumpAndSettle();

      // Validation errors should appear
      expect(find.text('Selecciona al menos un motivo del reporte.'), findsOneWidget);
      expect(find.text('El comentario es obligatorio para generar un reporte.'), findsOneWidget);

      // Select a reason chip
      final reasonChip = find.text('Calidad inferior a la ofrecida en catálogo');
      expect(reasonChip, findsOneWidget);
      await tester.tap(reasonChip);
      await tester.pumpAndSettle();

      // Type comment in TextField
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Producto en mal estado al ser entregado en almacén.');
      await tester.pumpAndSettle();

      // Counter should reflect typed characters
      expect(find.text('51 / 200'), findsOneWidget);

      // Submit valid report
      await tester.tap(find.text('Enviar Reporte'));
      await tester.pumpAndSettle();

      // Check report was registered in service
      final submitted = ReportsService.instance.allReports.firstWhere(
        (r) => r.reportedId == 'PROV-999',
      );
      expect(submitted.comment, equals('Producto en mal estado al ser entregado en almacén.'));
      expect(submitted.reasons, contains('Calidad inferior a la ofrecida en catálogo'));
    });

    testWidgets('ReportsScreen displays list, search, filters and moderation modal', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ReportsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Header and KPI summaries
      expect(find.text('Gestión de Reportes'), findsOneWidget);
      expect(find.text('Pendientes'), findsWidgets);
      expect(find.text('En Revisión'), findsWidgets);
      expect(find.text('Resueltos'), findsWidgets);

      // Search functionality
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Criollo');
      await tester.pumpAndSettle();

      // Should find report from 'Restaurante El Criollo'
      expect(find.text('Restaurante El Criollo'), findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Filter by role: 'A Proveedores'
      final provFilter = find.text('A Proveedores');
      expect(provFilter, findsOneWidget);
      await tester.tap(provFilter);
      await tester.pumpAndSettle();

      // Verify all shown reports have reportedRole == 'proveedor'
      expect(find.text('Don Pedro H. (AgroTecomán)'), findsOneWidget);

      // Open detail modal on first report card
      final viewDetailBtn = find.text('Ver Expediente').first;
      await tester.tap(viewDetailBtn);
      await tester.pumpAndSettle();

      expect(find.text('Detalle del Reporte'), findsOneWidget);
      expect(find.text('PARTICIPANTES DE LA INCIDENCIA'), findsOneWidget);
      expect(find.textContaining('COMENTARIO OBLIGATORIO'), findsOneWidget);
    });

    testWidgets('ReportsScreen renders cleanly on narrow mobile viewports (320px - 390px) without overflows', (tester) async {
      for (final width in [320.0, 360.0, 390.0]) {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: ReportsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gestión de Reportes'), findsOneWidget);
        expect(find.byType(ReportsScreen), findsOneWidget);
      }
    });

    testWidgets('ReportUserBottomSheet extracts and displays only the sector for user privacy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportUserBottomSheet(
              reportedId: 'BUY-88291',
              reportedName: 'Juan Pérez',
              reportedRole: 'comprador',
              reportedAvatar: '',
              reportedLocation: 'Central de Abastos • Cuauhtémoc, CDMX',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display ONLY the sector 'Cuauhtémoc, CDMX', hiding 'Central de Abastos'
      expect(find.textContaining('Cuauhtémoc, CDMX'), findsOneWidget);
      expect(find.textContaining('Central de Abastos'), findsNothing);
    });

    testWidgets('ReportUserBottomSheet shows active report card and blocks duplicate submission when active case exists', (tester) async {
      final service = ReportsService.instance;
      service.resetToMockData();

      // Ensure BUY-00000001 has active report against PROV-00000001
      expect(service.hasActiveReport('BUY-00000001', 'PROV-00000001'), isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportUserBottomSheet(
              reportedId: 'PROV-00000001',
              reportedName: 'Don Pedro H. (AgroTecomán)',
              reportedRole: 'proveedor',
              reportedAvatar: '',
              reportedLocation: 'Tecomán, Colima',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the active report banner
      expect(find.textContaining('Reporte Activo en Revisión'), findsOneWidget);
      expect(find.text('Entendido (Caso en Revisión)'), findsOneWidget);
      expect(find.text('Enviar Reporte'), findsNothing);
    });

    testWidgets('ReportedUsersScreen displays list and clicking Ver Reporte opens complete summary modal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReportedUsersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Usuarios Reportados'), findsOneWidget);
      expect(find.text('Carlos Rodríguez'), findsOneWidget);
      expect(find.text('Ana María López'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsWidgets);

      // Tap 'Ver Reporte' for Carlos Rodríguez
      final verReporteBtn = find.widgetWithText(ElevatedButton, 'Ver Reporte').first;
      await tester.tap(verReporteBtn);
      await tester.pumpAndSettle();

      // Verify modal opened with required summary sections
      expect(find.text('Resumen de Reporte'), findsOneWidget);
      expect(find.text('Usuario Reportado'), findsOneWidget);
      expect(find.text('Carlos Rodríguez'), findsWidgets);
      expect(find.text('Motivo(s) del reporte seleccionado(s)'), findsOneWidget);
      expect(find.text('Comentario colocado en el reporte'), findsOneWidget);
      expect(find.text('Cerrar Resumen'), findsOneWidget);

      // Tap close
      await tester.tap(find.text('Cerrar Resumen'));
      await tester.pumpAndSettle();
      expect(find.text('Resumen de Reporte'), findsNothing);
    });

    testWidgets('ReportUserBottomSheet prevents self-reporting and displays informational banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportUserBottomSheet(
              reportedId: 'BUY-00000001',
              reportedName: 'Juan Pérez',
              reportedRole: 'comprador',
              reportedAvatar: '',
              reportedLocation: 'Cuauhtémoc, CDMX',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show self-report warning banner
      expect(find.text('No puedes auto-reportarte'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);
      expect(find.text('Enviar Reporte'), findsNothing);
    });
  });
}

