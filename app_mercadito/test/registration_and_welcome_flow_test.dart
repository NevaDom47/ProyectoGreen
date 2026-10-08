import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_mercadito/screens/register_screen.dart';
import 'package:app_mercadito/screens/register_email_verification_screen.dart';
import 'package:app_mercadito/screens/welcome_screen.dart';
import 'package:app_mercadito/screens/select_role_screen.dart';
import 'package:app_mercadito/screens/login_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

Widget createTestRouterApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/verify-registration-email',
        builder: (context, state) => RegisterEmailVerificationScreen(
          email: state.extra as String?,
        ),
      ),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/select-role', builder: (context, state) => const SelectRoleScreen()),
      GoRoute(path: '/buyer-onboarding', builder: (context, state) => const Scaffold(body: Text('Buyer Onboarding Screen'))),
      GoRoute(path: '/provider-onboarding', builder: (context, state) => const Scaffold(body: Text('Provider Onboarding Screen'))),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home Feed Screen'))),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
  );
}

void main() {
  setUp(() {
    UserSession.clear();
  });

  group('RegisterScreen & Email Verification Flow Tests', () {
    testWidgets('RegisterScreen validates email and password fields with error feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestRouterApp(const RegisterScreen()));

      // Verify header and form elements are present
      expect(find.text('Crear cuenta nueva'), findsOneWidget);
      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar Contraseña'), findsOneWidget);

      // Tap submit with empty fields
      final submitBtn = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Email error should show
      expect(find.text('Por favor ingresa tu correo electrónico.'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextField).at(1), 'correo-invalido');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(find.text('Por favor ingresa un correo electrónico válido.'), findsOneWidget);

      // Enter valid email but short password
      await tester.enterText(find.byType(TextField).at(1), 'juan@ejemplo.com');
      await tester.enterText(find.byType(TextField).at(2), '1234');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(find.text('La contraseña debe tener al menos 8 caracteres.'), findsOneWidget);

      // Password mismatch
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password456');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('RegisterEmailVerificationScreen renders OTP inputs, timer, and error feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestRouterApp(
          const RegisterEmailVerificationScreen(email: 'test@mercadito.com'),
        ),
      );

      // Check header and content
      expect(find.text('Verifica tu correo'), findsOneWidget);
      expect(find.textContaining('test@mercadito.com'), findsOneWidget);
      expect(find.text('VERIFICAR Y CONTINUAR'), findsOneWidget);
      expect(find.textContaining('Reenviar código en'), findsOneWidget);

      // Tap verify button without entering full code
      final verifyBtn = find.text('VERIFICAR Y CONTINUAR');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();

      // Expect validation error
      expect(find.text('Por favor ingresa los 6 dígitos del código.'), findsOneWidget);

      // Enter 6 digits
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');
      await tester.enterText(textFields.at(4), '5');
      await tester.enterText(textFields.at(5), '6');
      await tester.pump();

      // Verify code
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pump(const Duration(milliseconds: 400));

      // Session email verified flag should be updated
      expect(UserSession.isEmailVerified, isTrue);
      expect(UserSession.email, 'test@mercadito.com');
    });

    testWidgets('WelcomeScreen renders 3-slide carousel, progresses slides, and navigates to SelectRoleScreen',
        (WidgetTester tester) async {
      // User has no role defined yet
      expect(UserSession.hasRole, isFalse);
      expect(UserSession.isFirstTimeUser, isTrue);

      await tester.pumpWidget(createTestRouterApp(const WelcomeScreen()));
      await tester.pumpAndSettle();

      // Slide 1 should be visible
      expect(find.textContaining('Bienvenido a'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);

      // Tap "Empezar" to go to slide 2
      final startBtn = find.text('Empezar');
      await tester.ensureVisible(startBtn);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      // Slide 2 should be visible
      expect(find.textContaining('Descubre Cosechas'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      // Tap "Continuar" to go to slide 3
      final continueBtn = find.text('Continuar');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Slide 3 should be visible
      expect(find.textContaining('Conéctate como'), findsOneWidget);
      expect(find.text('Seleccionar mi Rol'), findsOneWidget);

      // Until role is actually selected, isFirstTimeUser remains true
      expect(UserSession.isFirstTimeUser, isTrue);

      // Tap "Seleccionar mi Rol"
      final selectRoleBtn = find.text('Seleccionar mi Rol');
      await tester.ensureVisible(selectRoleBtn);
      await tester.tap(selectRoleBtn);
      await tester.pumpAndSettle();

      // Should now be on SelectRoleScreen
      expect(find.text('¿Cómo quieres participar?'), findsOneWidget);
    });

    testWidgets('SelectRoleScreen sets role and marks first-time user complete',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestRouterApp(const SelectRoleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('¿Cómo quieres participar?'), findsOneWidget);
      expect(find.text('Comprador'), findsWidgets);
      expect(find.text('Proveedor / Negociante'), findsWidgets);
      expect(find.text('CONTINUAR'), findsOneWidget);

      // Select Comprador
      await tester.tap(find.text('Comprador').first);
      await tester.pumpAndSettle();

      // Continue should be enabled
      final continueBtn = find.text('CONTINUAR');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pump();

      // Role is now registered
      expect(UserSession.selectedRole, 'comprador');
      expect(UserSession.hasRole, isTrue);
      expect(UserSession.isFirstTimeUser, isFalse);
    });

    testWidgets('LoginScreen always routes to WelcomeScreen if user has no defined role',
        (WidgetTester tester) async {
      expect(UserSession.hasRole, isFalse);

      await tester.pumpWidget(createTestRouterApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Enter credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'user@mercadito.com');
      await tester.enterText(textFields.at(1), 'password123');

      final loginBtn = find.text('Iniciar Sesión');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Should be redirected to WelcomeScreen carousel
      expect(find.textContaining('Bienvenido a'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
    });
  });
}
