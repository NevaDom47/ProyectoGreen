import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/business_hours_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

void main() {
  setUp(() {
    UserSession.clear();
  });

  testWidgets('BusinessHoursScreen renders all 7 days with switches and time pickers', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessHoursScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('Horario'), findsOneWidget);
    expect(find.text('Configura los días y horarios en los que tu negocio estará disponible.'), findsOneWidget);
    expect(find.text('Aplicar mismo horario a todos los días'), findsOneWidget);

    // Verify 7 days
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Martes'), findsOneWidget);
    expect(find.text('Miércoles'), findsOneWidget);
    expect(find.text('Jueves'), findsOneWidget);
    expect(find.text('Viernes'), findsOneWidget);
    expect(find.text('Sábado'), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);

    // Verify bottom button
    expect(find.text('GUARDAR HORARIO'), findsOneWidget);
  });

  testWidgets('Applying same schedule copies Monday to all days and saves to UserSession', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessHoursScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap quick action
    await tester.tap(find.text('Aplicar mismo horario a todos los días'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(tester.element(find.byType(BusinessHoursScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Tap Guardar Horario
    await tester.tap(find.widgetWithText(ElevatedButton, 'GUARDAR HORARIO'));
    await tester.pumpAndSettle();

    // Check UserSession
    expect(UserSession.weeklySchedule, isNotNull);
    expect(UserSession.weeklySchedule!.length, 7);
    expect(UserSession.weeklySchedule!.every((d) => d.isActive), isTrue);
    expect(UserSession.isSaturdayClosed, isFalse);
    expect(UserSession.isSundayClosed, isFalse);
  });
}
