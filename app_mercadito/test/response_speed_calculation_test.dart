import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/reviews_service.dart';
import 'package:app_mercadito/screens/chat_detail_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';

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

  group('Response Speed Tier Calculations (Calculo de velocidad de respuesta automatizada.md)', () {
    test('Tier scoring reflects exact time intervals from specification', () {
      // 0 a 5 minutos = 100 puntos (⚡ Inmediata)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(0), 100);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(3), 100);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(5), 100);

      // > 5 a 15 minutos = 90 puntos (🟢 Muy rápida)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(6), 90);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(10), 90);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(15), 90);

      // > 15 a 30 minutos = 75 puntos (🟢 Rápida)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(16), 75);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(25), 75);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(30), 75);

      // > 30 a 60 minutos = 50 puntos (🟡 Moderada)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(31), 50);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(45), 50);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(60), 50);

      // > 60 a 120 minutos = 25 puntos (🟠 Lenta)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(61), 25);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(90), 25);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(120), 25);

      // > 120 minutos = 0 puntos (🔴 Muy lenta)
      expect(ProviderResponseMetrics.scoreForResponseMinutes(121), 0);
      expect(ProviderResponseMetrics.scoreForResponseMinutes(240), 0);
    });

    test('Status labels match tier intervals', () {
      expect(ProviderResponseMetrics.statusLabelForMinutes(4), '⚡ Inmediata');
      expect(ProviderResponseMetrics.statusLabelForMinutes(12), '🟢 Muy rápida');
      expect(ProviderResponseMetrics.statusLabelForMinutes(22), '🟢 Rápida');
      expect(ProviderResponseMetrics.statusLabelForMinutes(45), '🟡 Moderada');
      expect(ProviderResponseMetrics.statusLabelForMinutes(90), '🟠 Lenta');
      expect(ProviderResponseMetrics.statusLabelForMinutes(150), '🔴 Lenta');
    });

    test('Calculate produces accurate speedScore, responseRate and compositeIndex', () {
      // 5 chats: [4 min (100), 10 min (90), 20 min (75), 50 min (50), 2 min (100)]
      // Total points: 415 / 5 = 83 speedScore
      // Average minutes: (4+10+20+50+2)/5 = 86/5 = 17 min
      // 10 received, 9 answered -> 90% responseRate
      // Composite: 83 * 0.7 + 90 * 0.3 = 58.1 + 27 = 85.1 -> 85
      final metrics = ProviderResponseMetrics.calculate(
        responseTimesMinutes: [4, 10, 20, 50, 2],
        totalConversationsReceived: 10,
        totalConversationsAnswered: 9,
      );

      expect(metrics.speedScore, 83);
      expect(metrics.averageResponseMinutes, 17);
      expect(metrics.responseRate, 90);
      expect(metrics.compositeIndex, 85);
      expect(metrics.formattedResponseTime, '17 minutos');
    });

    test('Hours formatting kicks in for response times over 60 minutes', () {
      final metrics = ProviderResponseMetrics.calculate(
        responseTimesMinutes: [90, 120],
        totalConversationsReceived: 5,
        totalConversationsAnswered: 5,
      );

      expect(metrics.averageResponseMinutes, 105);
      expect(metrics.formattedResponseTime, '1.8 horas');
    });
  });

  group('ChatDetailScreen Response Time Banner Widget Tests', () {
    testWidgets('Displays estimated response time popup and allows dismissing it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChatDetailScreen(
            provider: {
              'id': 'prov_test_speed',
              'name': 'Finca Don Pedro',
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify response time banner is visible
      expect(find.byKey(const ValueKey('chat_response_time_banner')), findsOneWidget);
      expect(find.textContaining('⚡ Tendrás respuesta aproximadamente'), findsOneWidget);
      expect(find.textContaining('Tiempo promedio habitual'), findsOneWidget);

      // Tap dismiss icon
      final dismissBtn = find.byKey(const ValueKey('dismiss_response_time_banner'));
      expect(dismissBtn, findsOneWidget);
      await tester.tap(dismissBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify banner is dismissed
      expect(find.byKey(const ValueKey('chat_response_time_banner')), findsNothing);
    });
  });
}
