import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/dashboard_screen.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/widgets/verified_badge.dart';

void main() {
  setUp(() {
    UserSession.verifiedCommercialName = 'Finca El Progreso';
    UserSession.businessDescription = 'Productos agrícolas y frescos';
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      home: DashboardScreen(),
    );
  }

  testWidgets('DashboardScreen renders clean producer header without notifications, settings, or active chip', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Business Title & Subtitle & Panel title
    expect(find.text('Panel Proveedor'), findsOneWidget);
    expect(find.text('Finca El Progreso'), findsOneWidget);
    expect(find.text('Productos agrícolas y frescos'), findsOneWidget);

    // Verify VerifiedBadge is present
    expect(find.byType(VerifiedBadge), findsOneWidget);

    // Verify Active status chip, notifications badge, and settings button are removed
    expect(find.text('Activo'), findsNothing);
    expect(find.text('3'), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
  });

  testWidgets('DashboardScreen renders Resumen de ventas card with 4 KPIs (Total Negociaciones, Negociaciones, etc.)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify section title
    expect(find.text('Resumen de ventas'), findsOneWidget);

    // Verify 4 KPI labels
    expect(find.text('Total Negociaciones'), findsOneWidget);
    expect(find.text('Negociaciones'), findsWidgets);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Calificación'), findsOneWidget);

    // Verify KPI trend badges
    expect(find.text('↑ 18% vs. semana anterior'), findsOneWidget);
    expect(find.text('↑ 12% vs. semana anterior'), findsWidgets);
    expect(find.text('↑ 9% vs. semana anterior'), findsOneWidget);
    expect(find.text('↑ 0.2 vs. semana anterior'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders Negociaciones diarias dual chart and period filters', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify chart title
    expect(find.text('Negociaciones diarias'), findsOneWidget);

    // Verify period pills
    expect(find.text('7 días'), findsOneWidget);
    expect(find.text('30 días'), findsOneWidget);
    expect(find.text('90 días'), findsOneWidget);

    // Verify legend
    expect(find.text('Ventas (RD\$)'), findsOneWidget);
    expect(find.text('Negociaciones'), findsWidgets);

    // Tap 30 días and verify interaction
    await tester.tap(find.text('30 días'));
    await tester.pumpAndSettle();
    expect(find.text('30 días'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders Recent Negotiations and Closing Rate sections', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Recent Negotiations title and action
    expect(find.text('Negociaciones recientes'), findsOneWidget);
    expect(find.text('Ver todas'), findsOneWidget);

    // Verify negotiation items and statuses
    expect(find.text('Tomate Saladette (10 kg)'), findsOneWidget);
    expect(find.text('Aguacate Hass (5 kg)'), findsOneWidget);
    expect(find.text('Limón Persa (20 kg)'), findsOneWidget);
    expect(find.text('Plátano Verde (50 uds)'), findsOneWidget);

    expect(find.text('Completado'), findsWidgets);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Cancelado'), findsOneWidget);

    // Verify Closing Rate Donut and Tip
    expect(find.text('Tu tasa de negociación'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);
    expect(find.text('Tasa de cierre'), findsOneWidget);
    expect(find.textContaining('Tu tasa de negociación ha mejorado'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders promotional Tus cupones activos banner with action', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify banner title
    expect(find.text('Tus cupones activos'), findsOneWidget);

    // Verify action button
    expect(find.text('Gestionar'), findsOneWidget);
  });

  testWidgets('DashboardScreen in dark mode uses #80C652 for header icons', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const DashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final barChartFinder = find.byIcon(Icons.bar_chart_rounded);
    expect(barChartFinder, findsOneWidget);
    final barChartIcon = tester.widget<Icon>(barChartFinder);
    expect(barChartIcon.color, const Color(0xFF80C652));

    final trendingUpFinder = find.byIcon(Icons.trending_up_rounded);
    expect(trendingUpFinder, findsOneWidget);
    final trendingUpIcon = tester.widget<Icon>(trendingUpFinder);
    expect(trendingUpIcon.color, const Color(0xFF80C652));

    final handshakeFinder = find.byIcon(Icons.handshake_outlined);
    expect(handshakeFinder, findsOneWidget);
    final handshakeIcon = tester.widget<Icon>(handshakeFinder);
    expect(handshakeIcon.color, const Color(0xFF80C652));
  });
}
