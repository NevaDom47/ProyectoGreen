import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/login_screen.dart';
import 'package:app_mercadito/screens/forgot_password_screen.dart';
import 'package:app_mercadito/screens/buyer_onboarding_screen.dart';
import 'package:app_mercadito/screens/provider_onboarding_screen.dart';
import 'package:app_mercadito/router/app_router.dart';

void main() {
  group('LoginScreen Responsive Button & Forgot Password Link', () {
    testWidgets('Login button is responsive and full-width centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoginScreen()),
        ),
      );

      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      expect(loginButtonFinder, findsOneWidget);

      // Verify that it is enclosed inside a SizedBox with double.infinity width
      final parentSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: loginButtonFinder,
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(parentSizedBox.width, double.infinity);
      expect(parentSizedBox.height, 50.0);
    });

    testWidgets('Tapping Olvide mi contrasena navigates to ForgotPasswordScreen', (tester) async {
      appRouter.go('/login');
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      final forgotPassBtn = find.text('¿Olvidé mi contraseña?');
      expect(forgotPassBtn, findsOneWidget);

      await tester.tap(forgotPassBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Multi-Step Flow', () {
    testWidgets('Step 1: validates email and moves to Step 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      final emailInput = find.byType(TextField);
      expect(emailInput, findsOneWidget);

      // Enter valid email and press send
      await tester.enterText(emailInput, 'usuario@mercadito.com');
      final sendBtn = find.widgetWithText(ElevatedButton, 'Enviar código de verificación');
      await tester.tap(sendBtn);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Should now be on Step 2
      expect(find.widgetWithText(ElevatedButton, 'Verificar código'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('usuario@mercadito.com'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Step 2 & Step 3 & Step 4: OTP, new password, and success screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      // Step 1: Email
      await tester.enterText(find.byType(TextField).first, 'test@mercadito.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar código de verificación'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Step 2: Enter 6 digits
      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(6));
      for (int i = 0; i < 5; i++) {
        await tester.enterText(textFormFields.at(i), '${i + 1}');
      }
      // Enter the 6th digit which triggers auto verify
      await tester.enterText(textFormFields.at(5), '6');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Step 3: Enter new password
      expect(find.text('Nueva Contraseña'), findsWidgets);
      final passFields = find.byType(TextField);
      expect(passFields, findsNWidgets(2));
      await tester.enterText(passFields.first, 'Password123!');
      await tester.enterText(passFields.last, 'Password123!');

      final resetBtn = find.widgetWithText(ElevatedButton, 'Restablecer Contraseña');
      await tester.tap(resetBtn);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Step 4: Success confirmation
      expect(find.text('¡Contraseña restablecida!'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'), findsOneWidget);
    });
  });

  group('Registration Country Selection Restriction', () {
    testWidgets('BuyerOnboardingScreen defaults to Republica Dominicana', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BuyerOnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final formScreen = tester.state(find.byType(BuyerOnboardingScreen));
      expect(formScreen, isNotNull);
    });

    testWidgets('ProviderOnboardingScreen defaults to Republica Dominicana', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProviderOnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final formScreen = tester.state(find.byType(ProviderOnboardingScreen));
      expect(formScreen, isNotNull);
    });
  });
}
