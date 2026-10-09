import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_mercadito/screens/tasks_screen.dart';
import 'package:app_mercadito/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('TasksScreen renders gamified hero, XP, streak, and awards points on task completion without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: TasksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar and Points
    expect(find.text('Tareas y Prestigio'), findsOneWidget);
    expect(find.text('1450 Pts'), findsOneWidget);

    // 2. Verify Hero Banner
    expect(find.text('NIVEL 3 • PRODUCTOR CONFIABLE'), findsOneWidget);
    expect(find.text('Puntos de Prestigio Acumulados'), findsOneWidget);
    expect(find.text('Progreso a Nivel 4 (Productor Oro)'), findsOneWidget);

    // 3. Verify Daily Summary and Streak
    expect(find.text('Resumen Diario'), findsOneWidget);
    expect(find.text('RACHA: 5 DÍAS'), findsOneWidget);
    expect(find.text('5'), findsNWidgets(2));
    expect(find.text('DE 10'), findsOneWidget);

    // 4. Verify Task Grid
    expect(find.text('Tareas Pendientes'), findsOneWidget);
    expect(find.text('Subir 1 Reel de Cosecha'), findsOneWidget);
    expect(find.text('Responder Mensajes'), findsOneWidget);
    expect(find.text('+50 Pts'), findsOneWidget);

    // 5. Test Interactive Task Reward (Tapping Reclamar on Responder Mensajes)
    final claimButton = find.text('Reclamar');
    expect(claimButton, findsOneWidget);
    await tester.ensureVisible(claimButton);
    await tester.pumpAndSettle();
    await tester.tap(claimButton);
    await tester.pumpAndSettle();

    // Verify Reward Dialog appears
    expect(find.text('¡Misión Cumplida!'), findsOneWidget);
    expect(find.text('+20 Pts de Prestigio'), findsOneWidget);

    // Dismiss dialog
    final continueButton = find.text('Continuar Jugando');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify points updated from 1450 to 1470
    expect(find.text('1470 Pts'), findsOneWidget);

    // Verify no RenderFlex overflows
    expect(tester.takeException(), isNull);
  });

  testWidgets('TasksScreen tap opens detail bottom sheet and Hacer triggers validation to make task reclamable', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: TasksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial state: 0 active tasks
    expect(find.text('0 activas'), findsOneWidget);

    // 2. Tap on task card 'Subir 1 Reel de Cosecha' to open detail sheet
    final taskCard = find.text('Subir 1 Reel de Cosecha');
    expect(taskCard, findsOneWidget);
    await tester.tap(taskCard);
    await tester.pumpAndSettle();

    // Verify detail sheet is visible with description, steps, and system validation box
    expect(find.text('Descripción de la Tarea'), findsOneWidget);
    expect(find.text('Pasos para Completar'), findsOneWidget);
    expect(find.text('Validación Automática del Sistema'), findsOneWidget);

    // Start task validation from the modal button
    final ctaButton = find.text('Hacer Misión (Iniciar Validación)');
    expect(ctaButton, findsOneWidget);
    await tester.tap(ctaButton);
    await tester.pumpAndSettle();

    // 3. Task is validated and now available to claim
    expect(find.text('Reclamar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('TasksScreen back button safely pops without assertion error when CustomBottomNavBar is present', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/tasks'),
                child: const Text('Ir a Tareas'),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
          ),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initially at /home with bottom nav bar
    expect(find.text('Ir a Tareas'), findsOneWidget);

    // 2. Navigate to /tasks
    await tester.tap(find.text('Ir a Tareas'));
    await tester.pumpAndSettle();

    expect(find.text('Tareas y Prestigio'), findsOneWidget);

    // 3. Tap back button (arrow_back)
    final backBtn = find.byIcon(Icons.arrow_back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // 4. Verify we are cleanly back at /home without _dependents.isEmpty or any exception
    expect(find.text('Ir a Tareas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TasksScreen in dark mode applies #80C652 to icons, points, and #2D402A to containers', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const TasksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Back Button Icon Color is #80C652
    final backIconFinder = find.byIcon(Icons.arrow_back);
    expect(backIconFinder, findsOneWidget);
    final Icon backIcon = tester.widget(backIconFinder);
    expect(backIcon.color, const Color(0xFF80C652));

    // 2. Verify Task Card Icon (Camera) has color #80C652
    final cameraIconFinder = find.byIcon(Icons.photo_camera_rounded);
    expect(cameraIconFinder, findsOneWidget);
    final Icon cameraIcon = tester.widget(cameraIconFinder);
    expect(cameraIcon.color, const Color(0xFF80C652));

    // 3. Verify Points pill (+50 Pts) has text color #80C652
    final points50Finder = find.text('+50 Pts');
    expect(points50Finder, findsOneWidget);
    final Text points50Text = tester.widget(points50Finder);
    expect(points50Text.style?.color, const Color(0xFF80C652));

    // 4. Verify Points pill (+20 Pts) has text color #80C652
    final points20Finder = find.text('+20 Pts');
    expect(points20Finder, findsOneWidget);
    final Text points20Text = tester.widget(points20Finder);
    expect(points20Text.style?.color, const Color(0xFF80C652));

    expect(tester.takeException(), isNull);
  });
}

