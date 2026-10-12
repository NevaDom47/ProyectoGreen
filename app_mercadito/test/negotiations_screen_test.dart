import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/negotiations_screen.dart';
import 'package:app_mercadito/theme/app_theme.dart';

void main() {
  testWidgets('NegotiationsScreen displays redesigned header, tabs, Mercado-style search, and cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const NegotiationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Negociaciones'), findsOneWidget);

    // Verify Tab headers
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
    expect(find.text('Canceladas'), findsOneWidget);

    // Verify search bar placeholder
    expect(find.text('Buscar producto o comprador...'), findsOneWidget);

    // Verify section title
    expect(find.text('Solicitudes Recientes'), findsOneWidget);

    // Verify pending negotiation cards
    expect(find.text('Tomate Saladette'), findsOneWidget);
    expect(find.text('Aguacate Hass'), findsOneWidget);
    expect(find.text('Limón Persa'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Cancelar'), findsWidgets);
    expect(find.text('Finalizar'), findsWidgets);

    // Open filter modal
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filtrar por Rol'), findsOneWidget);
    expect(find.text('Filtrar por Fecha'), findsOneWidget);

    // Tap on Proveedor filter option
    await tester.tap(find.text('Proveedor'));
    await tester.pumpAndSettle();

    // Switch to Completadas tab
    await tester.tap(find.text('Completadas'));
    await tester.pumpAndSettle();
    expect(find.text('Acuerdos Concretados'), findsOneWidget);

    // Switch to Canceladas tab
    await tester.tap(find.text('Canceladas'));
    await tester.pumpAndSettle();
    expect(find.text('Negociaciones Canceladas'), findsOneWidget);
  });

  testWidgets('Date picker in NegotiationsScreen in dark mode opens with dark theme and high contrast', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const NegotiationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Open filter bottom sheet
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar por Fecha'), findsOneWidget);
    expect(find.text('Seleccionar Fecha'), findsOneWidget);

    // Tap to open date picker
    await tester.tap(find.text('Seleccionar Fecha'));
    await tester.pumpAndSettle();

    // Date picker dialog should be open with Spanish / dark theme text
    expect(find.text('SELECCIONAR FECHA'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);
    expect(find.text('ACEPTAR'), findsOneWidget);

    // Tap CANCELAR to close date picker
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    // Back in bottom sheet
    expect(find.text('Filtrar por Fecha'), findsOneWidget);
  });
}
