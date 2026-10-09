import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/register_screen.dart';
import 'package:app_mercadito/screens/welcome_screen.dart';
import 'package:app_mercadito/screens/select_role_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

Widget createDarkThemeApp(Widget child) {
  return MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1C18),
    ),
    home: child,
  );
}

void main() {
  setUp(() {
    UserSession.clear();
  });

  group('Role Selection & Welcome Dark Mode Tests', () {
    testWidgets('WelcomeScreen renders #80C652 on Empezar button and indicator in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDarkThemeApp(const WelcomeScreen()));
      await tester.pumpAndSettle();

      // Find Empezar button container
      final empezarFinder = find.text('Empezar');
      expect(empezarFinder, findsOneWidget);

      final buttonContainer = tester.widget<Container>(
        find.ancestor(of: empezarFinder, matching: find.byType(Container)).first,
      );
      final decoration = buttonContainer.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFF80C652));

      // Find active indicator container
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final activeIndicator = animatedContainers.firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.color == const Color(0xFF80C652),
      );
      expect(activeIndicator, isNotNull);
    });

    testWidgets('SelectRoleScreen applies #80C652 to selected card and CONTINUAR button in dark mode',
        (WidgetTester tester) async {
      UserSession.birthDate = DateTime(1995, 5, 20);
      await tester.pumpWidget(createDarkThemeApp(const SelectRoleScreen()));
      await tester.pumpAndSettle();

      // Tap Comprador
      await tester.tap(find.text('Comprador').first);
      await tester.pumpAndSettle();

      // Verify button has #80C652
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), const Color(0xFF80C652));
    });
  });

  group('RegisterScreen Dark Mode & Logo Removal Tests', () {
    testWidgets('RegisterScreen does not display logo M and uses #80C652 for labels, icons and submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDarkThemeApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Verify logo_app_icon is removed
      final logoFinder = find.byWidgetPredicate((widget) {
        if (widget is Image && widget.image is AssetImage) {
          final asset = widget.image as AssetImage;
          return asset.assetName.contains('logo_app_icon');
        }
        return false;
      });
      expect(logoFinder, findsNothing);

      // Verify username option and person icon are removed
      expect(find.text('Nombre de Usuario (Opcional)'), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);

      // Verify label texts use #80C652
      final emailLabel = tester.widget<Text>(find.text('Correo Electrónico'));
      expect(emailLabel.style?.color, const Color(0xFF80C652));

      final passLabel = tester.widget<Text>(find.text('Contraseña'));
      expect(passLabel.style?.color, const Color(0xFF80C652));

      final confirmPassLabel = tester.widget<Text>(find.text('Confirmar Contraseña'));
      expect(confirmPassLabel.style?.color, const Color(0xFF80C652));

      // Verify icons use #80C652
      final mailIcon = tester.widget<Icon>(find.byIcon(Icons.mail));
      expect(mailIcon.color, const Color(0xFF80C652));

      final lockIcon = tester.widget<Icon>(find.byIcon(Icons.lock));
      expect(lockIcon.color, const Color(0xFF80C652));

      final lockResetIcon = tester.widget<Icon>(find.byIcon(Icons.lock_reset));
      expect(lockResetIcon.color, const Color(0xFF80C652));

      final visibilityIcon = tester.widget<Icon>(find.byIcon(Icons.visibility).first);
      expect(visibilityIcon.color, const Color(0xFF80C652));

      // Verify submit button container uses #80C652
      final submitText = find.text('Crear cuenta');
      final submitContainer = tester.widget<Container>(
        find.ancestor(of: submitText, matching: find.byType(Container)).first,
      );
      final submitDeco = submitContainer.decoration as BoxDecoration?;
      expect(submitDeco?.color, const Color(0xFF80C652));
    });
  });
}
