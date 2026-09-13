import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/all_tasks_screen.dart';

void main() {
  testWidgets('AllTasksScreen renders header, filters, task cards, modal sheet and executes validation flow without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AllTasksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar and Points
    expect(find.text('Todas las Tareas'), findsOneWidget);
    expect(find.text('1520 Pts'), findsOneWidget);

    // 2. Verify Progress Card
    expect(find.text('Progreso de Misiones'), findsOneWidget);
    expect(find.text('RACHA: 5 DÍAS'), findsOneWidget);

    // 3. Verify Filter Chips
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Por Reclamar'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);

    // 4. Verify Task items exist
    expect(find.text('Subir 1 Reel de Cosecha'), findsOneWidget);
    expect(find.text('Responder Mensajes Pendientes'), findsOneWidget);

    // 5. Test Filter Switching (Tap 'Por Reclamar')
    final filterChip = find.text('Por Reclamar');
    await tester.ensureVisible(filterChip);
    await tester.pumpAndSettle();
    await tester.tap(filterChip);
    await tester.pumpAndSettle();

    // In 'Por Reclamar', 'Responder Mensajes Pendientes' should be present, 'Subir 1 Reel de Cosecha' should be filtered out
    expect(find.text('Responder Mensajes Pendientes'), findsOneWidget);
    expect(find.text('Subir 1 Reel de Cosecha'), findsNothing);

    // Switch back to 'Todas'
    final allChip = find.text('Todas');
    await tester.ensureVisible(allChip);
    await tester.pumpAndSettle();
    await tester.tap(allChip);
    await tester.pumpAndSettle();
    expect(find.text('Subir 1 Reel de Cosecha'), findsOneWidget);

    // 6. Test Tap on Task card to open detail sheet
    await tester.tap(find.text('Subir 1 Reel de Cosecha'));
    await tester.pumpAndSettle();

    // Verify detail sheet is visible
    expect(find.text('Descripción de la Tarea'), findsOneWidget);
    expect(find.text('Pasos para Completar'), findsOneWidget);
    expect(find.text('Validación Automática del Sistema'), findsOneWidget);

    // Trigger validation from sheet
    final modalCta = find.text('Hacer Misión (Iniciar Validación)');
    expect(modalCta, findsOneWidget);
    await tester.tap(modalCta);
    await tester.pumpAndSettle();

    // 7. Verify task has been validated and button turned into 'Reclamar'
    // Now 'Subir 1 Reel de Cosecha' is reclamable
    // 8. Test claiming reward on 'Responder Mensajes Pendientes'
    final claimButtons = find.text('Reclamar');
    expect(claimButtons, findsAtLeastNWidgets(1));
    await tester.tap(claimButtons.first);
    await tester.pumpAndSettle();

    // Verify celebration modal
    expect(find.text('¡Misión Cumplida!'), findsOneWidget);
    final continueButton = find.text('Continuar');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify points updated (1520 + points)
    expect(find.text('1520 Pts'), findsNothing);

    // 9. Verify zero exceptions and zero overflows
    expect(tester.takeException(), isNull);
  });
}
