import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/providers_screen.dart';

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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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

  testWidgets('ProvidersScreen displays specialty dropdown and filters correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProvidersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header and Specialty Card are present
    expect(find.text('Proveedores'), findsOneWidget);
    expect(find.text('Especialidad del Proveedor'), findsOneWidget);
    expect(find.text('Horario de Atención'), findsOneWidget);
    expect(find.text('Todas las especialidades'), findsOneWidget);

    // Initial state: all providers shown (Cercanos default <= 10km)
    expect(find.text('Huerta Los Arcos'), findsOneWidget);

    // 2. Open Dropdown and choose 'Lácteos y Quesos Artesanales'
    // First, turn off Cercanos chip to allow Rancho San José (12km) or tap Cualquier horario
    await tester.tap(find.text('Cualquier horario'));
    await tester.pumpAndSettle();

    // Tap on Cercanos chip to unselect it so distance is not restricted to 10km
    await tester.tap(find.text('Cercanos'));
    await tester.pumpAndSettle();

    // Open specialty dropdown
    await tester.tap(find.text('Todas las especialidades'));
    await tester.pumpAndSettle();

    // Select 'Lacteos' in dropdown
    final lacteosItem = find.text('Lacteos').last;
    await tester.tap(lacteosItem);
    await tester.pumpAndSettle();

    // Verify only Rancho San José is displayed
    expect(find.text('Rancho San José'), findsOneWidget);
    expect(find.text('Huerta Los Arcos'), findsNothing);

    // 3. Clear specialty filter using 'Quitar' button
    expect(find.text('Quitar'), findsOneWidget);
    await tester.tap(find.text('Quitar'));
    await tester.pumpAndSettle();

    // Verify all providers return
    expect(find.text('Huerta Los Arcos'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Rancho San José'), findsOneWidget);

    // 4. Test Text Search in combination with specialty
    await tester.enterText(find.byType(TextField), 'Huerta');
    await tester.pumpAndSettle();

    expect(find.text('Huerta Los Arcos'), findsOneWidget);
    expect(find.text('Rancho San José'), findsNothing);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}
